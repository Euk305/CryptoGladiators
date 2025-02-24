;; ChainChampions Contract
;; Blockchain-based character collection, trading, and battles

(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_TRANSFER_FAILED (err u402))
(define-constant ERR_COOLDOWN (err u403))
(define-constant ERR_INVALID_INPUT (err u400))

(define-constant CONTRACT_OWNER tx-sender)
(define-constant MINT_PRICE u100000)
(define-constant MAX_LEVEL u100)
(define-constant BASE_XP_REQUIRED u100)
(define-constant MIN_PRICE u1000)
(define-constant MAX_CHARACTERS_PER_USER u100)

(define-data-var last-character-id uint u0)

(define-map characters
    uint
    {
        owner: principal,
        name: (string-ascii 24),
        level: uint,
        xp: uint,
        attack: uint,
        defense: uint,
        last-battle-block: uint
    }
)

(define-map user-character-count principal uint)

(define-map market
    uint
    {
        price: uint,
        seller: principal
    }
)
(define-private (is-valid-name (name (string-ascii 24)))
    (and (> (len name) u0) (<= (len name) u24))
)

(define-private (generate-stat (seed uint))
    (let ((hash (sha256 block-height)))
        (+ (mod (len hash) u10) u1)
    )
)

(define-read-only (get-owner-count (user principal))
    (default-to u0 (map-get? user-character-count user))
)

(define-public (mint-character (name (string-ascii 24)))
    (let (
            (new-id (+ (var-get last-character-id) u1))
            (caller tx-sender)
            (current-count (get-owner-count caller))
         )
         (asserts! (is-valid-name name) ERR_INVALID_INPUT)
         (asserts! (< current-count MAX_CHARACTERS_PER_USER) ERR_INVALID_INPUT)
         (try! (stx-transfer? MINT_PRICE caller CONTRACT_OWNER))
         (map-set characters new-id {
             owner: caller,
             name: name,
             level: u1,
             xp: u0,
             attack: (generate-stat new-id),
             defense: (generate-stat (+ new-id u1)),
             last-battle-block: u0
         })
         (map-set user-character-count caller (+ current-count u1))
         (var-set last-character-id new-id)
         (ok new-id)
    )
)
(define-private (is-valid-character-id (character-id uint))
    (<= character-id (var-get last-character-id))
)

(define-private (is-valid-price (price uint))
    (>= price MIN_PRICE)
)

(define-read-only (get-character (character-id uint))
    (map-get? characters character-id)
)

(define-read-only (get-listing (character-id uint))
    (map-get? market character-id)
)

(define-read-only (get-owner (character-id uint))
    (match (get-character character-id)
        character (ok (get owner character))
        ERR_NOT_FOUND
    )
)

(define-public (list-for-sale (character-id uint) (price uint))
    (begin
         (asserts! (is-valid-character-id character-id) ERR_INVALID_INPUT)
         (asserts! (is-valid-price price) ERR_INVALID_INPUT)
         (let ((owner (try! (get-owner character-id))))
              (asserts! (is-eq tx-sender owner) ERR_UNAUTHORIZED)
              (map-set market character-id { price: price, seller: tx-sender })
              (ok true)
         )
    )
)

(define-public (buy-character (character-id uint))
    (begin
         (asserts! (is-valid-character-id character-id) ERR_INVALID_INPUT)
         (let (
              (listing (unwrap! (get-listing character-id) ERR_NOT_FOUND))
              (price (get price listing))
              (seller (get seller listing))
              (buyer-count (get-owner-count tx-sender))
         )
         (asserts! (< buyer-count MAX_CHARACTERS_PER_USER) ERR_INVALID_INPUT)
         (try! (stx-transfer? price tx-sender seller))
         (map-delete market character-id)
         (let ((character (unwrap! (get-character character-id) ERR_NOT_FOUND)))
              (map-set characters character-id (merge character { owner: tx-sender }))
              (map-set user-character-count seller (- (get-owner-count seller) u1))
              (map-set user-character-count tx-sender (+ buyer-count u1))
              (ok true)
         )
         )
    )
)

