;;todo: 1. add right assoc support in shunting-yard-op func

(define (func-add xs)
  (cons (+ (cadr xs) (car xs)) (cddr xs)))

(define (func-sub xs)
  (cons (- (cadr xs) (car xs)) (cddr xs)))

(define (func-mul xs)
  (cons (* (cadr xs) (car xs)) (cddr xs)))

(define (func-div xs)
  (cons (/ (cadr xs) (car xs)) (cddr xs)))

(define (func-pow xs)
  (cons (expt (cadr xs) (car xs)) (cddr xs)))

(define (func-pos xs)
  (cons (car xs) (cdr xs)))

(define (func-neg xs)
  (cons (- (car xs)) (cdr xs)))

(struct oprec (sym prec func assoc) #:transparent
        #:property prop:custom-write
        (lambda (v p w?) (fprintf p "~a" (oprec-sym v))))

(define (shunting-yard-op prec func assoc toks ops outs)
  (cond [(null? ops)
         (shunting-yard (cdr toks)
                        (cons (oprec (car toks) prec func assoc) ops)
                        outs)]
        [(equal? 'lb (oprec-sym (car ops)))
         (shunting-yard (cdr toks)
                        (cons (oprec (car toks) prec func assoc) ops)
                        outs)] ;;what's this for again?
        [(and (>= prec (oprec-prec (car ops))) #t)
         (shunting-yard (cdr toks)
                        (cons (oprec (car toks) prec func assoc) ops)
                        outs)]
        [else
         (shunting-yard (cdr toks)
                        (cons (oprec (car toks) prec func assoc) (cdr ops))
                        (cons (car ops) outs)) ]))

(define (shunting-yard toks ops outs)
  (cond [(and (null? toks) (not (null? ops))
              (equal? 'lb (oprec-sym (car ops))) ) ;;lb
         (error "missing rb")]
        [(and (null? toks) (not (null? ops)))
         (shunting-yard toks (cdr ops) (cons (car ops) outs))]
        [(null? toks)
          outs]
        [(number? (car toks))
         (shunting-yard (cdr toks) ops (cons (car toks) outs))]
        [(equal? 'lb (car toks)) ;;lb ;;was this necessary or not again?
         ;; (shunting-yard-op 0 #f 'none toks ops outs)
         (shunting-yard (cdr toks) (cons (oprec 'lb #f #f #f) ops)
                        outs)]
        [(and (equal? 'rb (car toks)) (null? ops)) ;;rb
         (error "missing lb")]
        [(and (equal? 'rb (car toks))
              (equal? 'lb (oprec-sym (car ops)))) ;;rb
         (shunting-yard (cdr toks) (cdr ops) outs)]
        [(equal? 'rb (car toks)) ;;rb
         (shunting-yard toks (cdr ops) (cons (car ops) outs))]

        [(equal? '^ (car toks))
         (shunting-yard-op 4 func-pow 'right toks ops outs)]
        [(equal? '* (car toks))
         (shunting-yard-op 3 func-mul 'left toks ops outs)]
        [(equal? '/ (car toks))
         (shunting-yard-op 3 func-div 'left toks ops outs)]
        [(equal? '+ (car toks))
         (shunting-yard-op 2 func-add 'left toks ops outs)]
        [(equal? '- (car toks))
         (shunting-yard-op 2 func-sub 'left toks ops outs)]
        [(equal? 'u+ (car toks))
         (shunting-yard-op 4 func-pos 'left toks ops outs)]
        [(equal? 'u- (car toks))
         (shunting-yard-op 4 func-neg 'left toks ops outs)]

        [else
         (error "unknown token")]))

(define (calc rp stk)
  (cond [(null? rp) stk]
        [(number? (car rp))
         (calc (cdr rp) (cons (car rp) stk))]
        [else
         (calc (cdr rp) ((oprec-func (car rp)) stk))
         ]))

(define (test expr)
  (let* ([rp (shunting-yard expr '() '())]
         [val (calc (reverse rp) '())])
    (newline)
    (display expr) (newline)
    (display rp) (newline)
    (display val) (newline)
    (display (eval (car val))) (newline)

    ))

(test '(9 + 24 / u- lb 7 - 3 rb))
(test '(4 * 9 + 24 / lb 7 - 3 rb))
