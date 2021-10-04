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
  #:use-module (smc core state)
  #:use-module (smc version)
  #:use-module (smc fsm)
  #:export (write-header
            write-module
            write-use-modules
            write-transition-table
            form-feed))



(define (form-feed port)
  (display #\ff port))


;; Write a header commentary to a @var{port}.
(define (write-header port)
  (format port ";;; Generated by Guile-SMC ~a~%" (smc-version/string))
  (format port ";;; <https://github.com/artyom-poptsov/guile-smc>~%~%"))

;; Write a @code{define-module} part to a @var{port}. @var{class-name} is used
;; to export a FSM class in the @code{#:export} part. @var{extra-modules}
;; allow to specify a list of extra modules that required for the output FSM
;; to work.
(define (write-module module extra-modules class-name port)
  (let loop ((lst `(define-module ,module
                     #:use-module (oop goops)
                     #:use-module (smc fsm)))
             (em  extra-modules))
    (if (or (not em) (null? em))
        (begin
          (pretty-print (append lst `(#:export (,class-name)))
                        port)
          (newline port))
        (loop (append lst `(#:use-module ,(car em)))
              (cdr em)))))

;; Write 'use-modules' section to the @var{port}.
(define (write-use-modules extra-modules port)
  (let loop ((lst `(use-modules (smc fsm) (oop goops)))
             (em  extra-modules))
    (if (or (not em) (null? em))
        (begin
          (display lst port)
          (newline port))
        (loop (append lst (list (car em)))
              (cdr em)))))

;; Write a @var{fsm} transition table to a @var{port}.
(define-method (write-transition-table (fsm <fsm>) (port <port>))
  (let ((table (fsm-transition-table fsm)))
    (pretty-print
     `(define %transition-table
        ,(list 'quasiquote
               (map state->list/serialized
                    (hash-table->transition-list table))))
     port)))

;;; guile.scm ends here.
