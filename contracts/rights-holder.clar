;; Rights Holder Verification Contract
;; This contract validates legitimate water users

(define-data-var admin principal tx-sender)

;; Map to store verified rights holders
(define-map rights-holders principal bool)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-VERIFIED (err u101))
(define-constant ERR-NOT-VERIFIED (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Verify a rights holder
(define-public (verify-rights-holder (holder principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? rights-holders holder)) ERR-ALREADY-VERIFIED)
    (ok (map-set rights-holders holder true))))

;; Revoke verification
(define-public (revoke-verification (holder principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? rights-holders holder)) ERR-NOT-VERIFIED)
    (ok (map-delete rights-holders holder))))

;; Check if a principal is verified
(define-read-only (is-verified (holder principal))
  (default-to false (map-get? rights-holders holder)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))
