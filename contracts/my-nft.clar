
;; my-nft

(impl-trait .sip-009-trait.sip-009-trait)


(define-non-fungible-token my-nft uint)

(define-constant MINT_PRICE u1000000)
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

(define-data-var last-token-id uint u0)


(define-data-var multimint_recipient principal CONTRACT_OWNER)


(define-read-only (get-last-token-id) 
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint)) 
  (ok none)
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? my-nft id))
)

(define-public (transfer (id uint) (sender principal) (recipient principal)) 
  (begin 
  (asserts! (is-eq tx-sender sender) (err u101))
  ;; #[filter(id, recipient)]
  (nft-transfer? my-nft id sender recipient)
  )

)

(define-public (mint (recipient principal))
  (let 
    (
      (id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u100))
    ;; #[filter(recipient)]
    (try! (nft-mint? my-nft id recipient))
    (var-set last-token-id id)
    (ok id)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; here I am creating a multimint funktion which should is able to mint as much as is wanted whith one call
;; using the map function over a list. the length of the list determines the amount to be minted

(define-private (mint-helper (factor uint))
  (let 
    (
      (id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u100))
    (try! (nft-mint? my-nft id (var-get multimint_recipient)))
    (var-set last-token-id id)
    (ok id)
  )
)


(define-public (multimint (recipient principal) (nbr (list 100 uint)))
 (begin
 ;; #[filter(recipient)]
  (var-set multimint_recipient recipient)
  (ok (map mint-helper nbr))
)

)