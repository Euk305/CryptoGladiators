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
