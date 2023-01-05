;;; Generated by Guile-SMC 0.5.2
;;; <https://github.com/artyom-poptsov/guile-smc>


;;; This finite-state machine is produced by:
;;;   PlantUML <https://plantuml.com> Reader Finite-State Machine.
;;;   This FSM is a part of Guile State-Machine Compiler (Guile-SMC)
;;;   <https://github.com/artyom-poptsov/guile-smc>
;;;
;;; Statistics:
;;;   step-counter:              6201
;;;   transition-counter:         788
;;;
;;; Resolver status:
;;;   #<directory (smc context char-context)>
;;;     #<<generic> event-source (1)>
;;;     #<procedure #{guard:#t}# (ctx event)>
;;;     #<procedure action:clear-buffer (ctx event)>
;;;     #<procedure action:no-op (ctx event)>
;;;     #<procedure action:store (ctx event)>
;;;     #<procedure action:syntax-error (ctx ch)>
;;;     #<procedure action:update-stanza (ctx event)>
;;;     #<procedure guard:at-symbol? (ctx ch2)>
;;;     #<procedure guard:colon? (ctx ch2)>
;;;     #<procedure guard:eof-object? (ctx ch)>
;;;     #<procedure guard:hyphen-minus? (ctx ch2)>
;;;     #<procedure guard:left-square-bracket? (ctx ch2)>
;;;     #<procedure guard:less-than-sign? (ctx ch2)>
;;;     #<procedure guard:letter? (ctx ch)>
;;;     #<procedure guard:more-than-sign? (ctx ch2)>
;;;     #<procedure guard:newline? (ctx ch2)>
;;;     #<procedure guard:right-square-bracket? (ctx ch2)>
;;;     #<procedure guard:single-quote? (ctx ch2)>
;;;     #<procedure guard:space? (ctx ch2)>
;;;   #<directory (smc puml-context)>
;;;     #<procedure action:add-description (ctx ch)>
;;;     #<procedure action:add-state-transition (ctx ch)>
;;;     #<procedure action:check-end-tag (ctx)>
;;;     #<procedure action:check-start-tag (ctx ch)>
;;;     #<procedure action:process-state-description (ctx ch)>
;;;     #<procedure action:unexpected-end-of-file-error (ctx ch)>
;;;     #<procedure guard:title? (ctx ch)>


(define-module
  (smc puml-fsm)
  #:use-module
  (oop goops)
  #:use-module
  (smc fsm)
  #:use-module
  (smc context char)
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
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:colon?
        ,action:no-op
        read_state_description)
       (,guard:hyphen-minus?
        ,action:no-op
        read_state_right_arrow)
       (,guard:less-than-sign?
        ,action:no-op
        read_state_left_arrow)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition)))
    ((name . search_state_transition_guard)
     (description
       .
       "Check if the transition has a guard.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:letter?
        ,action:store
        read_state_transition_guard)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_guard)))
    ((name . read_start_tag)
     (description
       .
       "Read the start @startuml tag and check it for errors")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:space? ,action:check-start-tag read)
       (,guard:newline? ,action:check-start-tag read)
       (,#{guard:#t}# ,action:store read_start_tag)))
    ((name . read_state_description)
     (description
       .
       "Read a state description if it is present.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:newline?
        ,action:process-state-description
        read)
       (,#{guard:#t}#
        ,action:store
        read_state_description)))
    ((name . read_word)
     (description . "Read a word.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:title? ,action:clear-buffer read_title)
       (,guard:colon?
        ,action:update-stanza
        read_state_description)
       (,guard:space?
        ,action:update-stanza
        search_state_transition)
       (,#{guard:#t}# ,action:store read_word)))
    ((name . read_skip_comment)
     (description
       .
       "Skip commentaries that are written between stanzas.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:newline? ,action:no-op read)
       (,#{guard:#t}# ,action:no-op read_skip_comment)))
    ((name . read)
     (description
       .
       "Read the PlantUML transition table.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:at-symbol? ,action:store read_end_tag)
       (,guard:single-quote?
        ,action:no-op
        read_skip_comment)
       (,guard:left-square-bracket?
        ,action:no-op
        read_state)
       (,guard:letter? ,action:store read_word)
       (,#{guard:#t}# ,action:no-op read)))
    ((name . search_state_transition_action)
     (description
       .
       "Check if an action is present after the arrow.  Issue an error if it is not.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:letter?
        ,action:store
        read_state_transition_action)
       (,guard:newline? ,action:no-op #f)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_action)))
    ((name . read_state_left_arrow)
     (event-source unquote event-source)
     (transitions))
    ((name . read_state_right_arrow)
     (description
       .
       "Read a right arrow that indicates a transition.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:space?
        ,action:no-op
        search_state_transition_to)
       (,#{guard:#t}#
        ,action:no-op
        read_state_right_arrow)))
    ((name . read_end_tag)
     (description . "Read and check the @enduml tag.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:newline? ,action:no-op #f)
       (,guard:space? ,action:no-op #f)
       (,#{guard:#t}# ,action:store read_end_tag)))
    ((name . read_state_transition_guard)
     (description . "Read a state transition guard.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:space?
        ,action:update-stanza
        search_state_action_arrow)
       (,guard:newline?
        ,action:add-state-transition
        read)
       (,#{guard:#t}#
        ,action:store
        read_state_transition_guard)))
    ((name . read_state)
     (description . "Read a PlantUML stanza.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:newline? ,action:syntax-error #f)
       (,guard:right-square-bracket?
        ,action:update-stanza
        search_state_transition)
       (,guard:space?
        ,action:update-stanza
        search_state_transition)
       (,guard:colon?
        ,action:update-stanza
        read_state_description)
       (,#{guard:#t}# ,action:store read_state)))
    ((name . read_state_action_arrow)
     (description . "Read and skip the action arrow.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:newline? ,action:no-op #f)
       (,guard:more-than-sign?
        ,action:no-op
        search_state_transition_action)))
    ((name . read_state_transition_action)
     (description
       .
       "Read the state transition action.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:newline?
        ,action:add-state-transition
        read)
       (,#{guard:#t}#
        ,action:store
        read_state_transition_action)))
    ((name . read_state_transition_to)
     (description
       .
       "Read a state that the current state transitions to.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:right-square-bracket?
        ,action:no-op
        read_state_transition_to)
       (,guard:colon?
        ,action:update-stanza
        search_state_transition_guard)
       (,guard:newline?
        ,action:add-state-transition
        read)
       (,#{guard:#t}#
        ,action:store
        read_state_transition_to)))
    ((name . read_title)
     (description . "Read a diagram title.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object?
        ,action:unexpected-end-of-file-error
        #f)
       (,guard:newline? ,action:add-description read)
       (,#{guard:#t}# ,action:store read_title)))
    ((name . search_state_transition_to)
     (description
       .
       "Search for a state that the current state transitions to.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:letter?
        ,action:store
        read_state_transition_to)
       (,guard:left-square-bracket?
        ,action:no-op
        read_state_transition_to)
       (,#{guard:#t}#
        ,action:no-op
        search_state_transition_to)))
    ((name . search_state_action_arrow)
     (description
       .
       "Check if a transition has an attached action.")
     (event-source unquote event-source)
     (transitions
       (,guard:eof-object? ,action:no-op #f)
       (,guard:newline? ,action:no-op read)
       (,guard:hyphen-minus?
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
  (fsm-event-source-set! self event-source)
  (fsm-transition-table-set!
    self
    (transition-list->hash-table
      self
      %transition-table))
  (fsm-current-state-set!
    self
    (fsm-state self 'read_start_tag)))

