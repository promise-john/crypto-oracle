;; Title: CryptoOracle - Intelligent Bitcoin Price Prediction Markets
;; Summary: Advanced decentralized prediction platform for Bitcoin price movements
;; Description: CryptoOracle revolutionizes cryptocurrency price prediction through
;;              a sophisticated smart contract ecosystem built on Stacks blockchain.
;;              Users can leverage their market insights by staking STX tokens on
;;              Bitcoin's price trajectory, earning rewards based on accuracy and
;;              stake proportions. The protocol features dynamic market creation,
;;              oracle-verified price settlements, automated reward calculations,
;;              and robust security mechanisms. Designed for both retail traders
;;              and institutional participants seeking transparent, trustless
;;              exposure to Bitcoin price volatility through prediction markets.

;; CORE CONSTANTS

;; System Administration
(define-constant CONTRACT-OWNER tx-sender)

;; Comprehensive Error Code System
(define-constant ERR-OWNER-ONLY (err u100)) ;; Unauthorized access denied
(define-constant ERR-NOT-FOUND (err u101)) ;; Resource does not exist
(define-constant ERR-INVALID-PREDICTION (err u102)) ;; Malformed prediction data
(define-constant ERR-MARKET-CLOSED (err u103)) ;; Market trading window expired
(define-constant ERR-ALREADY-CLAIMED (err u104)) ;; Rewards previously claimed
(define-constant ERR-INSUFFICIENT-BALANCE (err u105)) ;; Inadequate STX balance
(define-constant ERR-INVALID-PARAMETER (err u106)) ;; Invalid function arguments

;; PLATFORM CONFIGURATION

;; Oracle Price Feed Configuration
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Economic Model Parameters
(define-data-var minimum-stake uint u1000000) ;; 1 STX minimum participation
(define-data-var fee-percentage uint u2) ;; 2% protocol revenue share
(define-data-var market-counter uint u0) ;; Sequential market numbering

;; DATA ARCHITECTURE

;; Primary Market Storage Schema
;; Encapsulates complete market lifecycle and participant data
(define-map markets
  uint ;; Unique market identifier
  {
    start-price: uint, ;; Bitcoin price at market inception (micro-units)
    end-price: uint, ;; Final settlement price (oracle-provided)
    total-up-stake: uint, ;; Cumulative bullish predictions (STX)
    total-down-stake: uint, ;; Cumulative bearish predictions (STX)
    start-block: uint, ;; Market opening block height
    end-block: uint, ;; Market closure block height
    resolved: bool, ;; Settlement completion status
  }
)

;; Participant Prediction Registry
;; Tracks individual user positions and claim status
(define-map user-predictions
  {
    market-id: uint, ;; Associated market reference
    user: principal, ;; Participant wallet address
  }
  {
    prediction: (string-ascii 4), ;; Market direction: "up" or "down"
    stake: uint, ;; STX tokens committed
    claimed: bool, ;; Payout distribution status
  }
)

;; PRIMARY PROTOCOL FUNCTIONS

;; MARKET CREATION ENGINE

(define-public (create-market
    (start-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let ((market-id (var-get market-counter)))
    ;; Administrative authorization verification
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)

    ;; Market parameter validation
    (asserts! (> end-block start-block) ERR-INVALID-PARAMETER)
    (asserts! (> start-price u0) ERR-INVALID-PARAMETER)

    ;; Initialize new market with default state
    (map-set markets market-id {
      start-price: start-price,
      end-price: u0,
      total-up-stake: u0,
      total-down-stake: u0,
      start-block: start-block,
      end-block: end-block,
      resolved: false,
    })

    ;; Advance global market counter
    (var-set market-counter (+ market-id u1))
    (ok market-id)
  )
)