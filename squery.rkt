;;
;; (string=? str1 str2 ...)

(define (squery2 qs as bs rs )
  (display (list qs as bs rs))
  (display #\newline)
  ;; (write (newline))
  (squery qs as bs rs) )

(define (squery qs as bs rs)
  (cond
   [(null? qs) #t]
   [(equal? (car qs) 'char)
         (let ([c (cadr qs)])
           (if (equal? c (car as))
               (squery2 '() (cdr as) bs rs)
               #f) )]
        [else #f]) )


(display #\newline)
(let* ([txt "#"]
       [txt2 (string->list txt)]
      ;;[q '(and (many0 (or " " "\t")) "#" (many0 (any)) )]
       [q '(char #\#)]
       [result (squery2 q txt2 '() '())]

       )

  (display result)

  )
