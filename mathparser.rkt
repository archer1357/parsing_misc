(define (parse l)
  (match l
    ;;transform
    [(? number? a) a]
    [`(noparse ,val) val]
    [`(,a) (parse a)]

    [`(,a ... + + ,b ... ) (parse `(,@a + ,@b))]
    [`(,a ... + - ,b ... ) (parse `(,@a - ,@b))]
    [`(,a ... - + ,b ... ) (parse `(,@a - ,@b))]
    [`(,a ... - - ,b ... ) (parse `(,@a + ,@b))]

    [`(,a ... * + ,b ,c ...) (parse `(,@a * (+ ,b) ,*c))]
    [`(,a ... * - ,b ,c ...) (parse `(,@a * (- ,b) ,*c))]
    [`(,a ... / + ,b ,c ...) (parse `(,@a / (+ ,b) ,*c))]
    [`(,a ... / - ,b ,c ...) (parse `(,@a / (- ,b) ,*c))]

    ;;grammar
    [`(+ ,a ,b ...) (parse `((noparse ,(parse a)) ,@b))]
    [`(- ,a ,b ...) (parse `((noparse ,`(- ,(parse a))) ,@b))]

    [`(,a ... + ,b ...) `(+ ,(parse a) ,(parse b))]
    [`(,a ... - ,b ...) `(- ,(parse a) ,(parse b))]
    [`(,a ... * ,b ...) `(* ,(parse a) ,(parse b))]
    [`(,a ... / ,b ...) `(/ ,(parse a) ,(parse b))]

    [else (error "parse error")]))

(eval
 (parse
  '(- - - (+ - + - 4) * (- 44 ) - 3 - - 9 )
  ))