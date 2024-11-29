;; Input validation functions
(define-private (is-valid-character-id (character-id uint))
    (<= character-id (var-get last-character-id))
)

(define-private (is-valid-price (price uint))
    (>= price MIN_PRICE)
)

(define-private (is-valid-name (name (string-ascii 24)))
    (and 
        (> (len name) u0)
        (<= (len name) u24)
    )
)

;; Update public functions with validation

;; Update mint-character
(define-public (mint-character (name (string-ascii 24)))
    (let
        (
            (new-id (+ (var-get last-character-id) u1))
            (caller tx-sender)
            (current-count (get-owner-count caller))
        )
        ;; Input validation
        (asserts! (is-valid-name name) ERR_INVALID_INPUT)
        (asserts! (< current-count MAX_CHARACTERS_PER_USER) ERR_INVALID_INPUT)
        
        (try! (stx-transfer? MINT_PRICE caller CONTRACT_OWNER))
        ;; Rest of the function remains the same
        ...
    )
)

;; Update list-for-sale
(define-public (list-for-sale (character-id uint) (price uint))
    (begin
        ;; Input validation
        (asserts! (is-valid-character-id character-id) ERR_INVALID_INPUT)
        (asserts! (is-valid-price price) ERR_INVALID_INPUT)
        
        ;; Rest of the function remains the same
        ...
    )
)

;; Update buy-character
(define-public (buy-character (character-id uint))
    (begin
        ;; Input validation
        (asserts! (is-valid-character-id character-id) ERR_INVALID_INPUT)
        
        ;; Rest of the function remains the same
        ...
    )
)

;; Update battle
(define-public (battle (attacker-id uint) (defender-id uint))
    (begin
        ;; Input validation
        (asserts! (is-valid-character-id attacker-id) ERR_INVALID_INPUT)
        (asserts! (is-valid-character-id defender-id) ERR_INVALID_INPUT)
        (asserts! (not (is-eq attacker-id defender-id)) ERR_INVALID_INPUT)
        
        ;; Rest of the function remains the same
        ...
    )
)