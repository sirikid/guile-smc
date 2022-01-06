;;; guile.scm -- Guile-SMC state machine compiler procedures.

;; Copyright (C) 2021 Artyom V. Poptsov <poptsov.artyom@gmail.com>
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; The program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; The procedures in this module produce a Scheme code for GNU Guile.


;;; Code:

(define-module (smc compiler guile)
  #:use-module (oop goops)
  #:use-module (ice-9 pretty-print)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 rdelim)
  #:use-module (smc core common)
  #:use-module (smc core state)
  #:use-module (smc core log)
  #:use-module (smc version)
  #:use-module (smc fsm)
  #:use-module (smc puml)
  #:use-module (smc config)
  #:export (write-header
            write-module
            write-use-modules
            write-transition-table
            write-parent-fsm-info
            write-define-class
            write-initialize
            copy-dependencies
            form-feed))



(define (form-feed port)
  "Write a form feed symbol with the following newline to a PORT."
  (display #\ff port)
  (newline port))



(define (write-header port)
  "Write a header commentary to a @var{port}."
  (format port ";;; Generated by Guile-SMC ~a~%" (smc-version/string))
  (format port ";;; <https://github.com/artyom-poptsov/guile-smc>~%~%"))

(define* (write-module module
                       #:key
                       extra-modules
                       class-name
                       port
                       (standalone-mode? #f))
  "Write a @code{define-module} part to a @var{port}. @var{class-name} is used
to export a FSM class in the @code{#:export} part. @var{extra-modules} allow
to specify a list of extra modules that required for the output FSM to work."
  (let loop ((lst `(define-module ,module
                     #:use-module (oop goops)
                     #:use-module ,(if standalone-mode?
                                       (append module '(smc fsm))
                                       '(smc fsm))))
             (em  extra-modules))
    (if (or (not em) (null? em))
        (begin
          (pretty-print (append lst `(#:export (,class-name)))
                        port)
          (newline port))
        (loop (append lst `(#:use-module ,(car em)))
              (cdr em)))))

(define (write-use-modules extra-modules port)
  "Write 'use-modules' section to the @var{port}."
  (let loop ((lst `(use-modules (smc fsm) (oop goops)))
             (em  extra-modules))
    (if (or (not em) (null? em))
        (begin
          (display lst port)
          (newline port))
        (loop (append lst (list (car em)))
              (cdr em)))))

(define-method-with-docs (write-transition-table (fsm <fsm>) (port <port>))
  "Write a @var{fsm} transition table to a @var{port}."
  (let ((table (fsm-transition-table fsm)))
    (pretty-print
     `(define %transition-table
        ,(list 'quasiquote
               (map state->list/serialized
                    (hash-table->transition-list table))))
     port)))

(define-method-with-docs (write-parent-fsm-info (fsm <fsm>) (port <port>))
  "Print the information about the parent FSM for a @var{fsm} to a @var{port}."
  (form-feed port)
  (display ";;; This finite-state machine is produced by:\n" port)
  (for-each (lambda (line) (format port ";;;   ~a~%" line))
            (string-split (regexp-substitute/global #f
                                                    "\\\\n"
                                                    (fsm-description (fsm-parent fsm))
                                                    'pre "\n" 'post)
                          #\newline))
  (display ";;;\n" port)

  (fsm-pretty-print-statistics (fsm-parent fsm) port)
  (display ";;;\n" port)
  (puml-context-print-resolver-status (fsm-parent-context fsm)
                                      port)
  (newline port))

(define (write-define-class class-name port)
  "Write @code{define-class} for a @var{class-name} to a @var{port}."
  (pretty-print `(define-class ,class-name (<fsm>))
                port))

(define (write-initialize fsm class-name port)
  "Write the class constructor for @var{class-name} to the @var{port}."
  (pretty-print
   `(define-method (initialize (self ,class-name) initargs)
      (next-method)
      (fsm-description-set! self ,(fsm-description fsm))
      (fsm-event-source-set! self ,(and (fsm-event-source fsm)
                                        (procedure-name (fsm-event-source fsm))))
      (fsm-transition-table-set!
       self
       (transition-list->hash-table self %transition-table))
      (fsm-current-state-set! self
                              (fsm-state self
                                         (quote ,(state-name (fsm-current-state fsm))))))
   port))



(define (copy-file/substitute source destination substitutes)
  (let ((src (open-input-file source))
        (dst (open-output-file destination)))
    (let loop ((line (read-line src)))
      (if (eof-object? line)
          (begin
            (close-port src)
            (close-port dst))
          (let ((ln (let matcher-loop ((subs substitutes)
                                       (ln   line))
                      (if (null? subs)
                          ln
                          (let ((s (car subs)))
                            (matcher-loop (cdr subs)
                                          (regexp-substitute/global #f
                                                                    (car s)
                                                                    ln
                                                                    'pre
                                                                    (cdr s)
                                                                    'post)))))))
            (write-line ln dst)
            (loop (read-line src)))))))

(define (copy-dependencies output-directory root-module-name)
  "Copy dependencies to a sub-directory with ROOT-MODULE-NAME of an
OUTPUT-DIRECTORY."
  (let* ((target-dir (format #f
                             "~a/~a"
                             output-directory
                             (string-join (map symbol->string root-module-name)
                                          "/")))
         (files      (list "/fsm.scm"
                           "/core/common.scm"
                           "/core/log.scm"
                           "/core/state.scm"
                           "/core/stack.scm"
                           "/core/transition.scm"
                           "/context/char-context.scm"
                           "/context/context.scm"))
         (substitutes (list (cons "\\(smc "
                                  (format #f
                                          "(~a smc "
                                          (string-join (map symbol->string
                                                            root-module-name)
                                                       " ")))
                            (cons ";;; Commentary:"
                                  (string-append
                                   ";;; Commentary:\n\n"
                                   (format #f ";; Copied from Guile-SMC ~a~%"
                                           (smc-version/string)))))))
    (mkdir target-dir)
    (mkdir (string-append target-dir "/smc"))
    (mkdir (string-append target-dir "/smc/core"))
    (mkdir (string-append target-dir "/smc/context"))

    (for-each (lambda (file)
                (let ((src (string-append %guile-smc-modules-directory file))
                      (dst (string-append target-dir "/smc/" file)))
                (log-debug "copying: ~a -> ~a ..." src dst)
                (copy-file/substitute src dst substitutes)
                (log-debug "copying: ~a -> ~a ... done" src dst)))
              files)))

;;; guile.scm ends here.
