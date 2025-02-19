;;; Generated by Guile-SMC 0.5.2
;;; <https://github.com/artyom-poptsov/guile-smc>


;;; This finite-state machine is produced by:
;;;   PlantUML <https://plantuml.com> Reader Finite-State Machine.
;;;   This FSM is a part of Guile State-Machine Compiler (Guile-SMC)
;;;   <https://github.com/artyom-poptsov/guile-smc>
;;;
;;; Statistics:
;;;   step-counter:              6197
;;;   transition-counter:         788
;;;
;;; Resolver status:
;;;   #<directory (smc context char)>
;;;     #<procedure #{guard:#t}# (ctx event)>
;;;     #<procedure action:no-op (ctx event)>
;;;     #<procedure char:at-symbol? (ctx ch2)>
;;;     #<procedure char:colon? (ctx ch2)>
;;;     #<procedure char:eof-object? (ctx ch)>
;;;     #<procedure char:hyphen-minus? (ctx ch2)>
;;;     #<procedure char:left-square-bracket? (ctx ch2)>
;;;     #<procedure char:less-than-sign? (ctx ch2)>
;;;     #<procedure char:letter? (ctx ch)>
;;;     #<procedure char:more-than-sign? (ctx ch2)>
;;;     #<procedure char:newline? (ctx ch2)>
;;;     #<procedure char:right-square-bracket? (ctx ch2)>
;;;     #<procedure char:single-quote? (ctx ch2)>
;;;     #<procedure char:space? (ctx ch2)>
;;;   #<directory (smc context oop char)>
;;;     #<procedure clear-buffer (context #:optional event)>
;;;     #<procedure push-buffer-to-stanza (context #:optional event)>
;;;     #<procedure push-event-to-buffer (context event)>
;;;     #<procedure throw-syntax-error (ctx ch)>
;;;   #<directory (smc puml-context)>
;;;     #<<generic> char-context-event-source (1)>
;;;     #<procedure add-description (ctx ch)>
;;;     #<procedure add-state-transition (ctx ch)>
;;;     #<procedure process-state-description (ctx ch)>
;;;     #<procedure throw-unexpected-end-of-file-error (ctx ch)>
;;;     #<procedure title? (ctx ch)>
;;;     #<procedure validate-end-tag (ctx ch)>
;;;     #<procedure validate-start-tag (ctx ch)>


(define-module
  (smc puml-fsm)
  #:use-module
  (oop goops)
  #:use-module
  (smc fsm)
  #:use-module
  (smc context char)
  #:use-module
  (smc context oop char)
  #:use-module
  (smc puml-context)
  #:re-export
  (fsm-run!)
  #:export
  (<puml-fsm>))



(define %transition-table
  `(((name . search_state_transition)
     (description
       .
       "Check if a state has a transition.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:colon?
        ,action:no-op
        read_state_description)
       (,char:hyphen-minus?
        ,action:no-op
        read_state_right_arrow)
       (,char:less-than-sign?
        ,action:no-op
        read_state_left_arrow)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition)))
    ((name . search_state_transition_guard)
     (description
       .
       "Check if the transition has a guard.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:letter?
        ,push-event-to-buffer
        read_state_transition_guard)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_guard)))
    ((name . read_start_tag)
     (description
       .
       "Read the start @startuml tag and check it for errors")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:space? ,validate-start-tag read)
       (,char:newline? ,validate-start-tag read)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_start_tag)))
    ((name . read_state_description)
     (description
       .
       "Read a state description if it is present.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:newline? ,process-state-description read)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_state_description)))
    ((name . read_word)
     (description . "Read a word.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,title? ,clear-buffer read_title)
       (,char:colon?
        ,push-buffer-to-stanza
        read_state_description)
       (,char:space?
        ,push-buffer-to-stanza
        search_state_transition)
       (,#{guard:#t}# ,push-event-to-buffer read_word)))
    ((name . read_skip_comment)
     (description
       .
       "Skip commentaries that are written between stanzas.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:newline? ,action:no-op read)
       (,#{guard:#t}# ,action:no-op read_skip_comment)))
    ((name . read)
     (description
       .
       "Read the PlantUML transition table.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:at-symbol?
        ,push-event-to-buffer
        read_end_tag)
       (,char:single-quote?
        ,action:no-op
        read_skip_comment)
       (,char:left-square-bracket?
        ,action:no-op
        read_state)
       (,char:letter? ,push-event-to-buffer read_word)
       (,#{guard:#t}# ,action:no-op read)))
    ((name . search_state_transition_action)
     (description
       .
       "Check if an action is present after the arrow.  Issue an error if it is not.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:letter?
        ,push-event-to-buffer
        read_state_transition_action)
       (,char:newline? ,action:no-op #f)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_action)))
    ((name . read_state_left_arrow)
     (event-source unquote char-context-event-source)
     (transitions))
    ((name . read_state_right_arrow)
     (description
       .
       "Read a right arrow that indicates a transition.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:space?
        ,action:no-op
        search_state_transition_to)
       (,#{guard:#t}#
        ,action:no-op
        read_state_right_arrow)))
    ((name . read_end_tag)
     (description . "Read and check the @enduml tag.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:newline? ,action:no-op #f)
       (,char:space? ,action:no-op #f)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_end_tag)))
    ((name . read_state_transition_guard)
     (description . "Read a state transition guard.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:space?
        ,push-buffer-to-stanza
        search_state_action_arrow)
       (,char:newline? ,add-state-transition read)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_state_transition_guard)))
    ((name . read_state)
     (description . "Read a PlantUML stanza.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:newline? ,throw-syntax-error #f)
       (,char:right-square-bracket?
        ,push-buffer-to-stanza
        search_state_transition)
       (,char:space?
        ,push-buffer-to-stanza
        search_state_transition)
       (,char:colon?
        ,push-buffer-to-stanza
        read_state_description)
       (,#{guard:#t}# ,push-event-to-buffer read_state)))
    ((name . read_state_action_arrow)
     (description . "Read and skip the action arrow.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:newline? ,action:no-op #f)
       (,char:more-than-sign?
        ,action:no-op
        search_state_transition_action)))
    ((name . read_state_transition_action)
     (description
       .
       "Read the state transition action.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:newline? ,add-state-transition read)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_state_transition_action)))
    ((name . read_state_transition_to)
     (description
       .
       "Read a state that the current state transitions to.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:right-square-bracket?
        ,action:no-op
        read_state_transition_to)
       (,char:colon?
        ,push-buffer-to-stanza
        search_state_transition_guard)
       (,char:newline? ,add-state-transition read)
       (,#{guard:#t}#
        ,push-event-to-buffer
        read_state_transition_to)))
    ((name . read_title)
     (description . "Read a diagram title.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object?
        ,throw-unexpected-end-of-file-error
        #f)
       (,char:newline? ,add-description read)
       (,#{guard:#t}# ,push-event-to-buffer read_title)))
    ((name . search_state_transition_to)
     (description
       .
       "Search for a state that the current state transitions to.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:letter?
        ,push-event-to-buffer
        read_state_transition_to)
       (,char:left-square-bracket?
        ,action:no-op
        read_state_transition_to)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_to)))
    ((name . search_state_action_arrow)
     (description
       .
       "Check if a transition has an attached action.")
     (event-source unquote char-context-event-source)
     (transitions
       (,char:eof-object? ,action:no-op #f)
       (,char:newline? ,action:no-op read)
       (,char:hyphen-minus?
        ,action:no-op
        read_state_action_arrow)
       (,#{guard:#t}#
        ,action:no-op
        search_state_action_arrow)))))


(define-class <puml-fsm> (<fsm>))


(define-method
  (initialize (self <puml-fsm>) initargs)
  (next-method)
  (fsm-description-set!
    self
    "PlantUML <https://plantuml.com> Reader Finite-State Machine.\\nThis FSM is a part of Guile State-Machine Compiler (Guile-SMC)\\n<https://github.com/artyom-poptsov/guile-smc>")
  (fsm-event-source-set!
    self
    char-context-event-source)
  (fsm-transition-table-set!
    self
    (transition-list->hash-table
      self
      %transition-table))
  (fsm-current-state-set!
    self
    (fsm-state self 'read_start_tag)))

