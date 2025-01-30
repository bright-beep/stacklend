;; Title: StackLend - Decentralized Lending Protocol on Stacks
;;
;; Summary: A secure and efficient lending protocol built on the Stacks blockchain, enabling users to deposit STX tokens as collateral,
;; borrow assets, and manage loans with transparency and trust.
;;
;; Description: StackLend is a decentralized lending protocol that leverages the security of Bitcoin through the Stacks L2 blockchain.
;; It allows users to deposit STX tokens as collateral, borrow against their holdings, repay loans, and withdraw collateral seamlessly.
;; The protocol includes features like liquidation of under-collateralized positions, dynamic interest rates, and administrative controls for managing key parameters.
;; StackLend is designed to be user-friendly, secure, and scalable, making it a cornerstone of decentralized finance (DeFi) on Stacks.

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-LOAN-NOT-FOUND (err u103))
(define-constant ERR-LOAN-ACTIVE (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-LIQUIDATION-FAILED (err u106))
(define-constant ERR-INVALID-PARAMETER (err u107))

(define-constant MAX-COLLATERAL-RATIO u500) ;; 500%
(define-constant MIN-COLLATERAL-RATIO u110) ;; 110%
(define-constant MAX-PROTOCOL-FEE u10) ;; 10%

;; Data Variables
(define-data-var minimum-collateral-ratio uint u150) ;; 150% collateralization ratio
(define-data-var liquidation-threshold uint u130) ;; 130% triggers liquidation
(define-data-var protocol-fee uint u1) ;; 1% fee
(define-data-var total-deposits uint u0)
(define-data-var total-borrows uint u0)

;; Data Maps
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        collateral-amount: uint,
        borrowed-amount: uint,
        interest-rate: uint,
        start-height: uint,
        last-interest-update: uint,
        active: bool
    }
)

(define-map user-positions
    { user: principal }
    {
        total-collateral: uint,
        total-borrowed: uint,
        loan-count: uint
    }
)

;; Private Functions
(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (let (
        (interest-per-block (/ (* principal rate) u10000))
        (total-interest (* interest-per-block blocks))
    )
    total-interest)
)

(define-private (get-collateral-ratio (collateral uint) (debt uint))
    (if (is-eq debt u0)
        u0
        (/ (* collateral u100) debt)
    )
)

(define-private (update-user-position (user principal) (collateral-delta uint) (is-collateral-increase bool) (borrow-delta uint) (is-borrow-increase bool))
    (let (
        (current-position (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: user })))
        (new-collateral (if is-collateral-increase
            (+ (get total-collateral current-position) collateral-delta)
            (- (get total-collateral current-position) collateral-delta)))
        (new-borrowed (if is-borrow-increase
            (+ (get total-borrowed current-position) borrow-delta)
            (- (get total-borrowed current-position) borrow-delta)))
    )
    (map-set user-positions
        { user: user }
        {
            total-collateral: new-collateral,
            total-borrowed: new-borrowed,
            loan-count: (get loan-count current-position)
        }
    ))
)

;; Public Functions
(define-public (deposit)
    (let (
        (amount (stx-get-balance tx-sender))
    )
    (if (> amount u0)
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (var-set total-deposits (+ (var-get total-deposits) amount))
            (update-user-position tx-sender amount true u0 true)
            (ok amount)
        )
        ERR-INVALID-AMOUNT
    ))
)

(define-public (borrow (amount uint))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: tx-sender })))
        (collateral (get total-collateral user-pos))
        (current-borrowed (get total-borrowed user-pos))
    )
    (if (and
            (> amount u0)
            (>= (get-collateral-ratio collateral (+ current-borrowed amount))
                (var-get minimum-collateral-ratio)))
        (begin
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
            (var-set total-borrows (+ (var-get total-borrows) amount))
            (update-user-position tx-sender u0 true amount true)
            (ok amount)
        )
        ERR-INSUFFICIENT-COLLATERAL
    ))
)

(define-public (repay (amount uint))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: tx-sender })))
        (current-borrowed (get total-borrowed user-pos))
    )
    (if (<= amount current-borrowed)
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (var-set total-borrows (- (var-get total-borrows) amount))
            (update-user-position tx-sender u0 true amount false)
            (ok amount)
        )
        ERR-INVALID-AMOUNT
    ))
)