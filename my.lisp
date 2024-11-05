lambda, symbol, list, string, f64, i64

(define (func a :i32 b :i32)
    (+a b 1))
    
(defun func (a :i32 b :i32)
    (+a b 1))

(defvar (a :i32) 4)

(if (= a b)
    1
    2)

(def a (lambda (a :i32 b :i32) (+ a b))
`(a b ,c)


(def m (mat3 1 0 0 0 1 0 0 0 1)
(def a (vec3 1 2 3))

(def c (* m a))


(def c (* (mat3 1 0 0 0 1 0 0 0 1) (vec3 1 2 3)))

(define a (expr
    (* (mat3 m) (vec3 v))
    ))

(def b (expr (len a)))
(defun (a b) (+ a b))

(swizzle-xy (vec3 1 2 3))
(.xzz  (vec3 1 2 3))

(struct Thing (a :i32 b :f32))

(.a thing)



(defm abc (a :i32 b :i32)
    (+ a b))




let a : i32 = 3;
if a < b {
}

while true {
}

for i = 0 .. 4 {
}

a?a:b

fn myfunc(a : i32, b : 32) {
}

struct Abc {
    a : i32,
    b : i32,
}

op * (a : i32, b : i32) {
    return a*b;
}