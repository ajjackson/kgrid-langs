#! /usr/bin/csi -script
(use srfi-1) ;; List tools
(use utils) ;; File I/O tools
(use matchable) ;; Pattern matching (for match-let)
(use fmt)

(define (lattice-vectors-from-poscar poscar-path)
(strings-to-nums-2darray
       (map string-split 
            (poscar-lattice-lines (read-lines poscar-path))))
)

(define (strings-to-nums-2darray strings-list)
  (define (f l) (map string->number l))
  (map f strings-list)
  )

(define (poscar-lattice-lines poscar-lines)
  ;; lattice vectors are lines 3-5
  (drop (take poscar-lines 5) 2)
  )


(define (dot vector1 vector2)
  ;; dot product of two vectors
  (define (acc-dotproduct v1 v2 total)
    (cond ((and (null? v1) (null? v2)) total)
          ((or (null? v1) (null? v2)) (abort "Vector length mismatch"))
          (else (acc-dotproduct (cdr v1) (cdr v2) (+ total (* (car v1) (car v2)))))
          ))
  (acc-dotproduct vector1 vector2 0)
  )

(define (cross v1 v2)
  ;; cross product of two 3-vectors
  (list (- (* (second v1) (third v2)) (* (third v1) (second v2)))
        (- (* (third v1) (first v2)) (* (first v1) (third v2)))
        (- (* (first v1) (second v2)) (* (second v1) (first v2)))
        ))

(define (lattice-volume v1 v2 v3)
  ;; volume of unit cell defined by three lattice vectors
  (dot v1 (cross v2 v3))
  )

(define (lattice-mat-volume m)
  ;; volume of unit cell defined by 3x3 matrix
  (lattice-volume (first m) (second m) (third m)
  ))

(define (norm l)
  ;; The norm (absolute length) of a vector specified by list l
  (sqrt (fold-right (lambda (x l) (+ (* x x) l))  0 l))
  )

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
