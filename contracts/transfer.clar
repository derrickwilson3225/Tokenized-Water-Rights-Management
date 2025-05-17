;; Transfer Contract
;; Manages temporary or permanent rights exchanges

(define-data-var admin principal tx-sender)

;; Structure for a transfer
(define-map transfers
  { transfer-id: uint }
  { from: principal, to: principal, amount: uint, expiry: (optional uint) })

(define-data-var transfer-nonce uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-TRANSFER-NOT-FOUND (err u106))

;; Check if caller is admin or the rights holder
(define-private (is-authorized (holder principal))
  (or (is-eq tx-sender (var-get admin)) (is-eq tx-sender holder)))

;; Create a new transfer
(define-public (create-transfer (from principal) (to principal) (amount uint) (expiry (optional uint)))
  (begin
    (asserts! (is-authorized from) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (let ((transfer-id (var-get transfer-nonce)))
      (var-set transfer-nonce (+ transfer-id u1))
      (ok (map-set transfers
                  { transfer-id: transfer-id }
                  { from: from, to: to, amount: amount, expiry: expiry })))))

;; Get transfer details
(define-read-only (get-transfer (transfer-id uint))
  (map-get? transfers { transfer-id: transfer-id }))

;; Cancel a transfer
(define-public (cancel-transfer (transfer-id uint))
  (let ((transfer (map-get? transfers { transfer-id: transfer-id })))
    (match transfer
      transfer-data (begin
        (asserts! (is-authorized (get from transfer-data)) ERR-NOT-AUTHORIZED)
        (ok (map-delete transfers { transfer-id: transfer-id })))
      ERR-TRANSFER-NOT-FOUND)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))
