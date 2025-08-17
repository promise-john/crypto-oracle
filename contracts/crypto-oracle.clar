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

;; PREDICTION PLACEMENT SYSTEM

(define-public (make-prediction
    (market-id uint)
    (prediction (string-ascii 4))
    (stake uint)
  )
  (let (
      (market (unwrap! (map-get? markets market-id) ERR-NOT-FOUND))
      (current-block stacks-block-height)
    )
    ;; Market availability window validation
    (asserts!
      (and
        (>= current-block (get start-block market))
        (< current-block (get end-block market))
      )
      ERR-MARKET-CLOSED
    )

    ;; Prediction validity checks
    (asserts! (or (is-eq prediction "up") (is-eq prediction "down"))
      ERR-INVALID-PREDICTION
    )
    (asserts! (>= stake (var-get minimum-stake)) ERR-INVALID-PREDICTION)
    (asserts! (<= stake (stx-get-balance tx-sender)) ERR-INSUFFICIENT-BALANCE)

    ;; Execute stake transfer to contract escrow
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))

    ;; Register participant prediction
    (map-set user-predictions {
      market-id: market-id,
      user: tx-sender,
    } {
      prediction: prediction,
      stake: stake,
      claimed: false,
    })

    ;; Update aggregate market statistics
    (map-set markets market-id
      (merge market {
        total-up-stake: (if (is-eq prediction "up")
          (+ (get total-up-stake market) stake)
          (get total-up-stake market)
        ),
        total-down-stake: (if (is-eq prediction "down")
          (+ (get total-down-stake market) stake)
          (get total-down-stake market)
        ),
      })
    )
    (ok true)
  )
)

;; ORACLE SETTLEMENT SYSTEM

(define-public (resolve-market
    (market-id uint)
    (end-price uint)
  )
  (let ((market (unwrap! (map-get? markets market-id) ERR-NOT-FOUND)))
    ;; Oracle authentication verification
    (asserts! (is-eq tx-sender (var-get oracle-address)) ERR-OWNER-ONLY)

    ;; Market closure timing validation
    (asserts! (>= stacks-block-height (get end-block market)) ERR-MARKET-CLOSED)
    (asserts! (not (get resolved market)) ERR-MARKET-CLOSED)
    (asserts! (> end-price u0) ERR-INVALID-PARAMETER)

    ;; Finalize market with settlement data
    (map-set markets market-id
      (merge market {
        end-price: end-price,
        resolved: true,
      })
    )
    (ok true)
  )
)

;; REWARD DISTRIBUTION MECHANISM

(define-public (claim-winnings (market-id uint))
  (let (
      (market (unwrap! (map-get? markets market-id) ERR-NOT-FOUND))
      (prediction (unwrap!
        (map-get? user-predictions {
          market-id: market-id,
          user: tx-sender,
        })
        ERR-NOT-FOUND
      ))
    )
    ;; Settlement and claim status validation
    (asserts! (get resolved market) ERR-MARKET-CLOSED)
    (asserts! (not (get claimed prediction)) ERR-ALREADY-CLAIMED)

    (let (
        ;; Determine market outcome based on price movement
        (winning-prediction (if (> (get end-price market) (get start-price market))
          "up"
          "down"
        ))
        (total-stake (+ (get total-up-stake market) (get total-down-stake market)))
        (winning-stake (if (is-eq winning-prediction "up")
          (get total-up-stake market)
          (get total-down-stake market)
        ))
      )
      ;; Verify participant predicted correctly
      (asserts! (is-eq (get prediction prediction) winning-prediction)
        ERR-INVALID-PREDICTION
      )

      (let (
          ;; Calculate proportional rewards and protocol fees
          (winnings (/ (* (get stake prediction) total-stake) winning-stake))
          (fee (/ (* winnings (var-get fee-percentage)) u100))
          (payout (- winnings fee))
        )
        ;; Execute reward distribution
        (try! (as-contract (stx-transfer? payout (as-contract tx-sender) tx-sender)))

        ;; Transfer protocol revenue
        (try! (as-contract (stx-transfer? fee (as-contract tx-sender) CONTRACT-OWNER)))

        ;; Prevent duplicate claims
        (map-set user-predictions {
          market-id: market-id,
          user: tx-sender,
        }
          (merge prediction { claimed: true })
        )
        (ok payout)
      )
    )
  )
)

;; INFORMATION ACCESS LAYER

;; Market Data Retrieval Interface
(define-read-only (get-market (market-id uint))
  (map-get? markets market-id)
)

;; Participant Prediction Query Interface
(define-read-only (get-user-prediction
    (market-id uint)
    (user principal)
  )
  (map-get? user-predictions {
    market-id: market-id,
    user: user,
  })
)

;; Contract Treasury Status
(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

;; Platform Configuration Overview
(define-read-only (get-platform-config)
  {
    oracle-address: (var-get oracle-address),
    minimum-stake: (var-get minimum-stake),
    fee-percentage: (var-get fee-percentage),
    market-counter: (var-get market-counter),
  }
)

;; ADMINISTRATIVE CONTROL PANEL

;; ORACLE MANAGEMENT

(define-public (set-oracle-address (new-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (is-eq new-address new-address) ERR-INVALID-PARAMETER)
    (ok (var-set oracle-address new-address))
  )
)

;; ECONOMIC PARAMETER TUNING

(define-public (set-minimum-stake (new-minimum uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> new-minimum u0) ERR-INVALID-PARAMETER)
    (ok (var-set minimum-stake new-minimum))
  )
)

(define-public (set-fee-percentage (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (<= new-fee u100) ERR-INVALID-PARAMETER)
    (ok (var-set fee-percentage new-fee))
  )
)

;; TREASURY MANAGEMENT

(define-public (withdraw-fees (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender)))
      ERR-INSUFFICIENT-BALANCE
    )
    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) CONTRACT-OWNER)))
    (ok amount)
  )
)
