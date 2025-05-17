;; Compliance Contract
;; Ensures adherence to regulatory requirements

(define-data-var admin principal tx-sender)

;; Map to store compliance status
(define-map compliance-status principal bool)

;; Map to store compliance violations
(define-map violations principal uint)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Set compliance status
(define-public (set-compliance-status (holder principal) (status bool))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map-set compliance-status holder status))))

;; Record a violation
(define-public (record-violation (holder principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (let ((current-violations (default-to u0 (map-get? violations holder))))
      (ok (map-set violations holder (+ current-violations u1))))))

;; Get compliance status
(define-read-only (get-compliance-status (holder principal))
  (default-to false (map-get? compliance-status holder)))

;; Get violation count
(define-read-only (get-violations (holder principal))
  (default-to u0 (map-get? violations holder)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))
