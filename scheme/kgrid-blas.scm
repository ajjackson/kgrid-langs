#! /usr/bin/csi -script
(use srfi-1) ;; List tools
(use utils) ;; File I/O tools
(use matchable) ;; Pattern matching (for match-let)
(use fmt)
(use blas) ;; linear algebra library

(define (lattice-vectors-from-poscar poscar-path)
(strings-to-nums-2darray
       (map string-split 
            (poscar-lattice-lines (read-lines poscar-path)))))

;; (define (strings-to-nums-2darray strings-list)
;;   (define (f l) (map string->number l))
;;   (map (lambda (l) (apply f32vector l)) (map f strings-list))
;;   )

(define (strings-to-nums-2darray strings-list)
  (let ((row-to-vector (lambda (l)
                         (apply f32vector (map string->number l)))))
    (map row-to-vector strings-list)
    
))

(define (poscar-lattice-lines poscar-lines)
  ;; lattice vectors are lines 3-5
  (drop (take poscar-lines 5) 2)
  )

;; Use a macro to wrap the BLAS function for dot product.
;; In this program the vector length is always 3...
;; (This is not a very sensible use of macros but I wanted to try it :-D)
(define-syntax dot
  (syntax-rules ()
    ((dot v1 v2) (sdot 3 v1 v2))))

;; We have to wrap norm in a real function or map won't work
(define (norm v) (snrm2 3 v))

(define (cross v1 v2)
  ;; Filthy emulation of array slicing. 
  ;; Could do this properly with a macro, but this is a simple case...
  (let ((<0> (lambda (v) (f32vector-ref v 0)))
        (<1> (lambda (v) (f32vector-ref v 1)))
        (<2> (lambda (v) (f32vector-ref v 2))))

  ;; cross product of two 3-vectors
  (f32vector (- (* (<1> v1) (<2> v2)) (* (<2> v1) (<1> v2)))
        (- (* (<2> v1) (<0> v2)) (* (<0> v1) (<2> v2)))
        (- (* (<0> v1) (<1> v2)) (* (<1> v1) (<0> v2)))
        )))


(define (lattice-volume v1 v2 v3)
  ;; volume of unit cell defined by three lattice vectors
  (dot v1 (cross v2 v3))
  )

(define (lattice-mat-volume m)
  ;; volume of unit cell defined by 3x3 matrix
  (lattice-volume (first m) (second m) (third m)
  ))

(define (parse-args args cutoff input-file verbose?)
  ;; Return cutoff length, path to file and verbosity as a list from defaults and input args
  (cond ((null? args) (list cutoff input-file verbose?))
        ((equal? (car args) "-c")
         (parse-args (cddr args) (string->number (cadr args)) input-file verbose?))
        ((equal? (car args) "-f")
         (parse-args (cddr args) cutoff (cadr args) verbose?))
        ((equal? (car args) "-v")
         (parse-args (cdr args) cutoff input-file #t))
        (else
         (parse-args (cdr args) cutoff (car args) verbose?))
        ))

(define (ms-samples a cutoff)
  ;; k-points to achieve cutoff on lattice vector length a according to Moreno-Soler procedure
  (ceiling (* 2 (/ cutoff a)))
  )

(define (main)
  
  (match-let* (((cutoff input-file verbose?) (parse-args (command-line-arguments) 10 "POSCAR" #f))
               (lattice-vectors (lattice-vectors-from-poscar input-file))
               (lattice-lengths (map norm lattice-vectors))
               (kgrid (map (lambda (x) (ms-samples x cutoff)) lattice-lengths)))

              (if verbose? (define vprint fmt)
                  (define (vprint . args) #f))
              (vprint #t "Unit cell volume: " (fix 4 (lattice-mat-volume lattice-vectors)) "\n")
              (vprint #t "K-point mesh: ")
              (for-each (lambda (x) (fmt #t (inexact->exact x) " ")) kgrid)
              (print "")
             ))
              
(main)
