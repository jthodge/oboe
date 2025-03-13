#lang racket

;; Main entry point
(require "oboe-core.rkt"
         "oboe-examples.rkt")

;; Re-export core functionality
(provide (all-from-out "oboe-core.rkt")
         (all-from-out "oboe-examples.rkt"))

;; Run examples when in main module
(module+ main
  (run-examples))
