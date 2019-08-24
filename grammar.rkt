
;an idea to try is to have partial complete parsings exposed in structs amd/or lists rather than hidden in lambda funcs
;another idea is to store the grammar as a tree of structs, rather than a closure of lambdas, and/or store a parse tree instead of producing lists of results, and then run through the parse tree and get the end result

;;so basically instead of redoing the same parses on multiple parts of the tree, use a hashmap with the key being the parse position, and the value being the parse tree at that position, thus allowing the parser to skip generating new parse trees for positions that have already been done (like on left recursive grammars). Akin to simplifying an equation.

;overall need to reduce the amount of memory used!

;(module grammar racket
(struct grammar-return (value from to) #:transparent)
(struct grammar-thunk (outer inner index) #:transparent)

(define (lexer src ind p ws)
  (let ([a (regexp-match-positions p src ind)])
    (cond [(and a (= ind (caar a))) (car a)]
          [ws (let ((b (lexer src ind ws #f)))
                (if b (lexer src (cdr b) p ws) #f))]
          [else #f])))

(define (eot? src ind ws)
  (let ([l (string-length src)])
    (or (= ind l)
        (and ws
             (let ([r (lexer src ind ws #f)])
               (and r (= l (cdr r))))))))

(define hhh (make-hash))

(define (step src ws a m)
  (cond [(pair? a)
         (let ([aa (step src ws (car a) m)])
           (cons aa
                 (if (null? (cdr a))
                     null
                     (step src ws (cdr a) m))))]
        [(grammar-return? a) a]
       [(grammar-thunk? a)
        (let ([outer (grammar-thunk-outer a)]
              [inner (grammar-thunk-inner a)]
              [index (grammar-thunk-index a)])
          (let ([h1 (hash-ref hhh (cons index inner) (lambda () #f))])
            (if h1
                (begin
                  ;(printf "~a~n" (cons index h1))
                  (outer h1)
                  )
                (let ([qqq (inner src index ws)])
                  (hash-set! hhh (cons index inner) qqq)
                  ;(printf "~a~n" (cons index qqq))
                  (outer qqq)))))]
        [else #f]))

(define (result-found? a src ws)
  (cond [(pair? a) (ormap (lambda (x) (result-found? x src ws)) a)]
        [(and (grammar-return? a) (eot? src (grammar-return-to a) ws)) a]
        [else #f]))

(define (result-fail? a src ws)
  (if (pair? a)
      (andmap (lambda (x) (result-fail? x src ws)) a)
      (not a)))

(define (find-result a src ws)
  (let ([q (result-found? a src ws)])
    (cond [q q]
          [(result-fail? a src ws) #f]
          [else (find-result (step src ws a #f) src ws)])))

(define (parse-grammar g src ws)
  (let ([x (g src 0 ws)])
    (cond [x (find-result x src ws)]
          [else #f])))


(define (grammar-or-func self a b at-end src ind ws)
  (list
   (grammar-thunk (lambda (q) q) a ind)
   (grammar-thunk (lambda (q) q) b ind)
   ))

(define (and-bla g f ind)
  (cond [(pair? g) (map (lambda (p) (and-bla p f ind)) g)]
        [(procedure? g) (grammar-thunk f g ind)]
        [(grammar-thunk? g)
         (grammar-thunk (lambda (i) (f ((grammar-thunk-outer g) i)))
                        (grammar-thunk-inner g)
                        (grammar-thunk-index g))]
        [else #f]))

(define (and-return x y at-end)
  (grammar-return
   (if at-end
       (list (grammar-return-value x)
             (grammar-return-value y))
       (cons (grammar-return-value x)
             (grammar-return-value y)))
   (grammar-return-from x)
   (grammar-return-to y)))

(define (grammar-and-func a b at-end src ind ws)
  (letrec ([f1
            (lambda (x)
              (letrec ([f2
                        (lambda (y)
                          (if (grammar-return? y)
                              (and-return x y at-end)
                              (begin
                                ;(printf "no ~a~n" ind)
                                (and-bla y f2 ind)
                                )
                              ))])
                (if (grammar-return? x)
                    (begin
                      ;(printf "yes ~a~n" (grammar-return-to x))
                      (and-bla b f2 (grammar-return-to x))
                      )
                    (begin
                      ;(printf "no ~a~n" ind)
                      (and-bla x f1 ind)
                    )
                    )))])
    (and-bla a f1 ind)
    ))

(define (grammar-token-func ptn src ind ws)
  (let ([x (lexer src ind ptn ws)])
    (if x
        (grammar-return (substring src (car x) (cdr x)) (car x) (cdr x))
        #f)))

(define-syntax grammar-or-end
  (syntax-rules ()
    [(_ a b)
     (letrec ([self
               (lambda (src ind ws)
                 (grammar-or-func self a b #t src ind ws))])
       self)]))

(define-syntax grammar-or
  (syntax-rules ()
    [(_ a b)
     (letrec ([self
               (lambda (src ind ws)
                 (grammar-or-func self a b #f src ind ws))])
       self)]))

(define-syntax grammar-and-end
  (syntax-rules ()
    [(_ a b)
     (lambda (src ind ws)
       (grammar-and-func a b #t src ind ws))]))

(define-syntax grammar-and
  (syntax-rules ()
    [(_ a b)
     (lambda (src ind ws)
       (grammar-and-func a b #f src ind ws))]))

;; (define-syntax grammar-with
;;   (syntax-rules ()
;;     [(_ g f)
;;      (lambda (src ind ws)
;;        (grammar-with-func g f src ind ws))]))

(define-syntax grammar-token
  (syntax-rules ()
    [(_ ptn)
     (lambda (src ind ws)
       (grammar-token-func ptn src ind ws))]))

(define-syntax grammar-expr
  (syntax-rules (and or with token)
    ;[(_ (or a)) a]
    [(_ (or (a ...) (b ...)))
     (let ([x (grammar-expr (a ...))]
           [y (grammar-expr (b ...))])
       (grammar-or-end x y))]
    [(_ (or (a ...) b))
     (let ([x (grammar-expr (a ...))])
       (grammar-or-end x b))]
    [(_ (or a (b ...)))
     (let ([y (grammar-expr (b ...))])
       (grammar-or-end a y))]
    [(_ (or a b))
     (grammar-or-end a b)]
    [(_ (or (a ...) b ...))
     (let ([x (grammar-expr (a ...))]
           [y (grammar-expr (or b ...))])
       (grammar-or x y))]
    [(_ (or a b ...))
     (let ([y (grammar-expr (or b ...))])
       (grammar-or a y))]
    ;[(_ (and a)) a]
    [(_ (and (a ...) (b ...)))
     (let ([x (grammar-expr (a ...))]
           [y (grammar-expr (b ...))])
       (grammar-and-end x y))]
    [(_ (and (a ...) b))
     (let ([x (grammar-expr (a ...))])
       (grammar-and-end x b))]
    [(_ (and a (b ...)))
     (let ([y (grammar-expr (b ...))])
       (grammar-and-end a y))]
    [(_ (and a b))
     (grammar-and-end a b)]
    [(_ (and (a ...) b ...))
     (let ([x (grammar-expr (a ...))]
           [y (grammar-expr (and b ...))])
       (grammar-and x y))]
    [(_ (and a b ...))
     (let ([y (grammar-expr (and b ...))])
       (grammar-and a y))]
    ;; [(_ (with (a ...) b))
    ;;  (let ([x (grammar-expr (a ...))])
    ;;    (grammar-with x b))]
    ;; [(_ (with a b))
    ;;  (grammar-with a b)]
    [(_ (token a))
     (let ([ptn a])
       (grammar-token ptn))]))

(define-syntax grammar
  (syntax-rules (and or with token)
    [(_ (and a ...)) (grammar-expr (and a ...))]
    [(_ (or a ...)) (grammar-expr (or a ...))]
    ;[(_ (with a ...)) (grammar-expr (with a ...))]
    [(_ (token a ...)) (grammar-expr (token a ...))]
    [(_ [a b] [c d] ...)
     (letrec-values ([(a c ...)
                      (values (grammar-expr b) (grammar-expr d) ...)])
       a)]))

(define-syntax step-test
  (syntax-rules ()
    [(_ g src ws)
       (let ([r null])
         (lambda ()
           (if (not (null? r))
               (begin (set! r (step src ws r #f)) r)
               (begin (set! r (g src 0 ws)) r))))]))

;(provide grammar parse-grammar))

(define qq (grammar [a (or (and a (token #px"\\+") b)
                           (and a (token #px"-") b)
                           b)]
                    [b (or (and num (token #px"\\*") b)
                           (and num (token #px"/") b)
                           num)]
                    [num (token #px"[1-9][0-9]*")]))

(parse-grammar qq "1+2+3*3*4/7" #px"\\s")

;; (define pp (grammar [a (or a num idn)]
;;                     [num (token #px"[1-9][0-9]*")]
;;                     [idn (token #px"[_a-zA-Z][_a-zA-Z0-9]*")]))

; (parse-grammar pp "66" #px"\\s")
;(define h (step-test qq "3+2" #px"\\s"))
;(printf "~a~n" (h))
;(begin (h) #t)

;(<82:9> <85:9>)
;(<173:5> (<82:9> <85:9>))
;((<164:22> <164:22>) (<173:5> (<82:9> <85:9>)))
;((<164:22> (<164:22> <164:22>))
;;((<164:22> <164:22>) (<173:5> (<82:9> <85:9>))))
