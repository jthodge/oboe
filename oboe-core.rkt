#lang racket

;; Core implementation of the oboe Language
;; Integers are adjusted by random amount between 40-50 (inclusive) when stored or read
;;
;; Based on XKCD #3062: https://xkcd.com/3062/
;; Inspired by Shriram Krishnamurthi's implelmentation: https://github.com/shriram/xkcd-3062

(provide 
 ;; Main evaluation functions
 off-by-one-eval
 off-by-one-eval-string
 
 ;; Environment management
 global-env
 make-environment
 lookup
 define-var!
 
 ;; Integer adjustment
 adjust-integer)

;; Core function to randomly adjust integers
(define (adjust-integer n)
  (if (integer? n)
      ;; Random value between [40-50]
      (let ([adjustment (+ 40 (random 11))]
            [direction (if (zero? (random 2)) 1 -1)])
        (+ n (* adjustment direction)))
      ;; Non-integers pass through unchanged
      n))

;; Implement environment with adjustment on read/write
(struct environment (table parent) #:mutable)

;; Create a new environment
(define (make-environment [parent #f])
  (environment (make-hash) parent))

;; Create global environment
(define global-env (make-environment))

;; Look up a variable, apply adjustment to integers
(define (lookup var env)
  (cond
    [(environment? env)
     (let ([table (environment-table env)])
       (if (hash-has-key? table var)
           (let ([value (hash-ref table var)])
             (let ([adjusted (adjust-integer value)])
               ;; Update stored value
               ;; Values are changed on read
               (hash-set! table var adjusted)
               adjusted))
           (if (environment-parent env)
               (lookup var (environment-parent env))
               (error 'lookup "Undefined variable: ~a" var))))]
    [else (error 'lookup "Invalid environment")]))

;; Define a variable, apply adjustment to integers
(define (define-var! var val env)
  (hash-set! (environment-table env) var (adjust-integer val)))

;; Apply a procedure to arguments
(define (apply-proc proc args)
  (apply proc args))

;; Initialize global environment with basic Racket functions
(for ([func (list + - * / < > <= >= = 
                 display displayln newline
                 list cons car cdr null?
                 append)])
  (define-var! (object-name func) func global-env))

;; Evaluator with adjustment handling
(define (evaluate expr env)
  (match expr
    ;; Self-evaluating expressions
    [(? number? n) (adjust-integer n)]
    [(? string? s) s]
    [(? boolean? b) b]
    
    ;; Variable reference
    [(? symbol? var) (lookup var env)]
    
    ;; Definition
    [`(define ,var ,val-expr) 
     (define-var! var (evaluate val-expr env) env)
     var]
    
    ;; Function definition
    [`(define (,name . ,params) . ,body)
     (define-var! 
       name
       (lambda args
         (let ([local-env (make-environment env)])
           (for ([param params]
                 [arg args])
             (define-var! param arg local-env))
           (evaluate-sequence body local-env)))
       env)
     name]
    
    ;; Lambda expression
    [`(lambda ,params . ,body)
     (lambda args
       (let ([local-env (make-environment env)])
         (for ([param params]
               [arg args])
           (define-var! param arg local-env))
         (evaluate-sequence body local-env)))]
    
    ;; If expression
    [`(if ,test-expr ,then-expr ,else-expr)
     (if (evaluate test-expr env)
         (evaluate then-expr env)
         (evaluate else-expr env))]
    
    ;; Begin sequence of expressions
    [`(begin . ,exprs)
     (evaluate-sequence exprs env)]
    
    ;; Set!
    [`(set! ,var ,val-expr)
     (let ([val (evaluate val-expr env)])
       (define-var! var val env)
       val)]
    
    ;; Function application
    [`(,op . ,operands)
     (let ([proc (evaluate op env)]
           [args (map (lambda (x) (evaluate x env)) operands)])
       (apply-proc proc args))]
    
    ;; Error for unknown expressions
    [_ (error 'evaluate "Unknown expression type: ~a" expr)]))

;; Evaluate a sequence of expressions, return the last result
(define (evaluate-sequence exprs env)
  (for/last ([expr (in-list exprs)])
    (evaluate expr env)))

;; Public interface
(define (off-by-one-eval expr)
  (evaluate expr global-env))

(define (off-by-one-eval-string str)
  (let ([exprs (call-with-input-string str
                 (lambda (port)
                   (let loop ([result '()])
                     (let ([expr (read port)])
                       (if (eof-object? expr)
                           (reverse result)
                           (loop (cons expr result)))))))])
    (evaluate `(begin ,@exprs) global-env)))
