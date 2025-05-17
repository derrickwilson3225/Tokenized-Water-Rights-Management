;; Usage Tracking Contract
;; Monitors actual water consumption

(define-data-var admin principal tx-sender)

;; Map to store water usage (principal -> usage amount)
(define-map usage principal uint)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-USAGE (err u104))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Record water usage
(define-public (record-usage (holder principal) (amount uint))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-USAGE)
    (let ((current-usage (default-to u0 (map-get? usage holder))))
      (ok (map-set usage holder (+ current-usage amount))))))

;; Get total usage for a rights holder
(define-read-only (get-usage (holder principal))
  (default-to u0 (map-get? usage holder)))

;; Reset usage for a new period
(define-public (reset-usage (holder principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (map-set usage holder u0))))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))
