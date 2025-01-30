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