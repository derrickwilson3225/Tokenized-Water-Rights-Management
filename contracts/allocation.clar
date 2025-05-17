;; Allocation Contract
;; Records permitted withdrawal amounts

(define-data-var admin principal tx-sender)

;; Map to store water allocations (principal -> allocation amount)
(define-map allocations principal uint)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ZERO-ALLOCATION (err u103))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Set allocation for a rights holder
(define-public (set-allocation (holder principal) (amount uint))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-ZERO-ALLOCATION)
    (ok (map-set allocations holder amount))))

;; Get allocation for a rights holder
(define-read-only (get-allocation (holder principal))
  (default-to u0 (map-get? allocations holder)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))
