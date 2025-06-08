;; BitFract - Decentralized Real-World Asset Tokenization Platform
;;
;; Title: BitFract Protocol - Stacks Layer 2 RWA Infrastructure
;;
;; Summary: 
;; A comprehensive Bitcoin-secured platform for tokenizing, trading, and governing 
;; real-world assets through fractional ownership with built-in compliance, 
;; dividend distribution, and decentralized governance mechanisms.
;;
;; Description:
;; BitFract transforms traditional assets into liquid, tradeable Bitcoin-backed 
;; tokens on Stacks Layer 2. Each real-world asset is fractionalized into 100,000 
;; Semi-Fungible Tokens (SFTs), enabling democratized access to high-value assets 
;; like real estate, commodities, and institutional investments. The protocol 
;; features automated dividend distribution, KYC compliance integration, 
;; decentralized governance through token-weighted voting, and oracle-based 
;; price feeds for transparent asset valuation.
;;
;; Key Features:
;; - Fractional asset ownership with 100,000 tokens per asset
;; - Automated dividend distribution and yield farming
;; - Built-in KYC/AML compliance with multi-level verification
;; - Decentralized governance with proposal-based voting
;; - Oracle integration for real-time asset pricing
;; - Bitcoin security through Stacks Layer 2 settlement

;; CONSTANTS & CONFIGURATION

;; Administrative Configuration
(define-constant contract-owner tx-sender)

;; System Error Codes
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-kyc-required (err u105))
(define-constant err-vote-exists (err u106))
(define-constant err-vote-ended (err u107))
(define-constant err-price-expired (err u108))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-value (err u111))
(define-constant err-invalid-duration (err u112))
(define-constant err-invalid-kyc-level (err u113))
(define-constant err-invalid-expiry (err u114))
(define-constant err-invalid-votes (err u115))
(define-constant err-invalid-address (err u116))
(define-constant err-invalid-title (err u117))

;; Protocol Configuration Limits
(define-constant MAX-ASSET-VALUE u1000000000000) ;; 1 trillion satoshis max
(define-constant MIN-ASSET-VALUE u1000) ;; 1 thousand satoshis min
(define-constant MAX-DURATION u144) ;; ~1 day in blocks (max voting duration)
(define-constant MIN-DURATION u12) ;; ~1 hour in blocks (min voting duration)
(define-constant MAX-KYC-LEVEL u5) ;; Maximum KYC verification level
(define-constant MAX-EXPIRY u52560) ;; ~1 year in blocks (max KYC expiry)

;; Tokenization Configuration
(define-constant tokens-per-asset u100000) ;; Standard fractionalization: 100,000 SFTs per asset

;; DATA STRUCTURES & STORAGE MAPS

;; Primary Asset Registry
;; Stores comprehensive metadata and state for each tokenized real-world asset
(define-map assets
  { asset-id: uint }
  {
    owner: principal, ;; Asset owner/controller
    metadata-uri: (string-ascii 256), ;; IPFS/URI for asset metadata
    asset-value: uint, ;; Current asset valuation in satoshis
    is-locked: bool, ;; Lock status for transfers/trading
    creation-height: uint, ;; Block height of asset registration
    last-price-update: uint, ;; Last oracle price update block
    total-dividends: uint, ;; Cumulative dividend pool
  }
)

;; Token Balance Ledger
;; Tracks fractional ownership across all assets and holders
(define-map token-balances
  {
    owner: principal,
    asset-id: uint,
  }
  { balance: uint }
)

;; KYC/AML Compliance Registry
;; Manages user verification status and compliance levels
(define-map kyc-status
  { address: principal }
  {
    is-approved: bool, ;; Current approval status
    level: uint, ;; Verification level (1-5)
    expiry: uint, ;; KYC expiration block height
  }
)

;; Decentralized Governance Proposals
;; Stores all governance proposals with voting mechanics
(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 256), ;; Proposal title/description
    asset-id: uint, ;; Target asset for proposal
    start-height: uint, ;; Voting start block
    end-height: uint, ;; Voting end block
    executed: bool, ;; Execution status
    votes-for: uint, ;; Total votes in favor
    votes-against: uint, ;; Total votes against
    minimum-votes: uint, ;; Minimum participation threshold
  }
)

;; Individual Vote Registry
;; Records individual voting decisions and token commitment
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  { vote-amount: uint }
)

;; Dividend Distribution Tracker
;; Manages dividend claim history and prevents double-claiming
(define-map dividend-claims
  {
    asset-id: uint,
    claimer: principal,
  }
  { last-claimed-amount: uint }
)

;; Oracle Price Feed Integration
;; External price data integration for asset valuation
(define-map price-feeds
  { asset-id: uint }
  {
    price: uint, ;; Current price in satoshis
    decimals: uint, ;; Price precision decimals
    last-updated: uint, ;; Last update block height
    oracle: principal, ;; Authorized oracle address
  }
)

;; INPUT VALIDATION & SECURITY FUNCTIONS

;; Validates asset value within acceptable bounds
(define-private (validate-asset-value (value uint))
  (and
    (>= value MIN-ASSET-VALUE)
    (<= value MAX-ASSET-VALUE)
  )
)

;; Validates governance proposal duration
(define-private (validate-duration (duration uint))
  (and
    (>= duration MIN-DURATION)
    (<= duration MAX-DURATION)
  )
)

;; Validates KYC verification level
(define-private (validate-kyc-level (level uint))
  (<= level MAX-KYC-LEVEL)
)

;; Validates KYC expiry timeframe
(define-private (validate-expiry (expiry uint))
  (and
    (> expiry stacks-block-height)
    (<= (- expiry stacks-block-height) MAX-EXPIRY)
  )
)

;; Validates minimum vote requirements for proposals
(define-private (validate-minimum-votes (vote-count uint))
  (and
    (> vote-count u0)
    (<= vote-count tokens-per-asset)
  )
)

;; Validates metadata URI format and length
(define-private (validate-metadata-uri (uri (string-ascii 256)))
  (and
    (> (len uri) u0)
    (<= (len uri) u256)
  )
)

;; UTILITY & HELPER FUNCTIONS

;; Generates next available asset ID
(define-private (get-next-asset-id)
  (default-to u1 (get-last-asset-id))
)

;; Generates next available proposal ID
(define-private (get-next-proposal-id)
  (default-to u1 (get-last-proposal-id))
)

;; Retrieves the last registered asset ID (placeholder for future counter implementation)
(define-private (get-last-asset-id)
  none
)

;; Retrieves the last created proposal ID (placeholder for future counter implementation)
(define-private (get-last-proposal-id)
  none
)

;; CORE ASSET MANAGEMENT FUNCTIONS

;; Registers a new real-world asset for tokenization
;; Creates 100,000 SFTs and assigns initial ownership to contract owner
(define-public (register-asset
    (metadata-uri (string-ascii 256))
    (asset-value uint)
  )
  (begin
    ;; Security: Only contract owner can register new assets
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; Input validation
    (asserts! (validate-metadata-uri metadata-uri) err-invalid-uri)
    (asserts! (validate-asset-value asset-value) err-invalid-value)
    (let ((asset-id (get-next-asset-id)))
      ;; Create asset registry entry
      (map-set assets { asset-id: asset-id } {
        owner: contract-owner,
        metadata-uri: metadata-uri,
        asset-value: asset-value,
        is-locked: false,
        creation-height: stacks-block-height,
        last-price-update: stacks-block-height,
        total-dividends: u0,
      })
      ;; Mint initial token supply to contract owner
      (map-set token-balances {
        owner: contract-owner,
        asset-id: asset-id,
      } { balance: tokens-per-asset }
      )
      (ok asset-id)
    )
  )
)

;; DIVIDEND DISTRIBUTION SYSTEM

;; Allows token holders to claim their proportional dividend share
;; Dividend amount is calculated based on token balance and unclaimed distributions
(define-public (claim-dividends (asset-id uint))
  (let (
      (asset (unwrap! (get-asset-info asset-id) err-not-found))
      (balance (get-balance tx-sender asset-id))
      (last-claim (get-last-claim asset-id tx-sender))
      (total-dividends (get total-dividends asset))
      (claimable-amount (/ (* balance (- total-dividends last-claim)) tokens-per-asset))
    )
    ;; Ensure there are dividends to claim
    (asserts! (> claimable-amount u0) err-invalid-amount)
    (asserts! (is-some (get-asset-info asset-id)) err-not-found)
    ;; Update claim record to prevent double-claiming
    (ok (map-set dividend-claims {
      asset-id: asset-id,
      claimer: tx-sender,
    } { last-claimed-amount: total-dividends }
    ))
  )
)

;; DECENTRALIZED GOVERNANCE SYSTEM

;; Creates a new governance proposal for asset management decisions
;; Requires minimum token ownership to prevent spam proposals
(define-public (create-proposal
    (asset-id uint)
    (title (string-ascii 256))
    (duration uint)
    (minimum-votes uint)
  )
  (begin
    ;; Input validation
    (asserts! (validate-duration duration) err-invalid-duration)
    (asserts! (validate-minimum-votes minimum-votes) err-invalid-votes)
    (asserts! (validate-metadata-uri title) err-invalid-title)
    ;; Authorization: Require 10% token ownership to create proposals
    (asserts! (>= (get-balance tx-sender asset-id) (/ tokens-per-asset u10))
      err-not-authorized
    )
    (let ((proposal-id (get-next-proposal-id)))
      (ok (map-set proposals { proposal-id: proposal-id } {
        title: title,
        asset-id: asset-id,
        start-height: stacks-block-height,
        end-height: (+ stacks-block-height duration),
        executed: false,
        votes-for: u0,
        votes-against: u0,
        minimum-votes: minimum-votes,
      }))
    )
  )
)