#lang racket

;; Examples for the oboe language

(require "oboe-core.rkt")

(provide run-examples)

(define (run-examples)
  (displayln "Off-by-one language example usage:\n")
  
  (displayln "Example 1: Basic arithmetic")
  (displayln "Original: (+ 5 10)")
  (displayln (format "Result: ~a\n" (off-by-one-eval '(+ 5 10))))
  
  (displayln "Example 2: Variable definitions")
  (off-by-one-eval '(define x 100))
  (displayln "Defined x = 100")
  (displayln (format "Reading x first time: ~a" (off-by-one-eval 'x)))
  (displayln (format "Reading x second time: ~a\n" (off-by-one-eval 'x)))
  
  (displayln "Example 3: Functions")
  (displayln "Result:")
  (off-by-one-eval-string "
    (define sum 0)
    (define count 10)
    
    (define (add-to-sum n)
      (set! sum (+ sum n))
      sum)
    
    (add-to-sum count)
    (add-to-sum count)
    (display \"Final sum: \")
    sum
  "))
