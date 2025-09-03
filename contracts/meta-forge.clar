;; MetaForge Protocol
;; 
;; Revolutionary Web3 Gaming Infrastructure for the Next Generation
;;
;; MetaForge transforms traditional gaming through blockchain technology,
;; creating a unified ecosystem where digital assets transcend individual games.
;; Players can forge legendary items, evolve persistent characters, and compete
;; in interconnected virtual worlds while earning real economic value.
;;
;; Key Innovations:
;; - Cross-Platform Asset Portability - Items work across multiple games
;; - Algorithmic Rarity Engine - Dynamic scarcity based on player behavior  
;; - Skill-Based Token Economics - Rewards tied to gameplay mastery
;; - Community-Governed Tournaments - Player-driven competitive events
;; - Persistent Character Evolution - Characters grow across game boundaries
;;
;; Built on Stacks for Bitcoin-secured transactions with lightning-fast gameplay.

;; CONSTANTS & ERROR DEFINITIONS

;; Error Constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-ASSET (err u101))
(define-constant ERR-INSUFFICIENT-FUNDS (err u102))
(define-constant ERR-INVALID-INPUT (err u103))
(define-constant ERR-NOT-FOUND (err u104))
(define-constant ERR-ALREADY-EXISTS (err u105))
(define-constant ERR-MAX-LIMIT-REACHED (err u106))
(define-constant ERR-INVALID-RARITY (err u107))

;; Game Mechanics
(define-constant MAX-LEVEL u100)
(define-constant BASE-XP-MULTIPLIER u100)
(define-constant MAX-LEADERBOARD-SIZE u100)
(define-constant MIN-NAME-LENGTH u3)
(define-constant MAX-NAME-LENGTH u50)
(define-constant MAX-DESCRIPTION-LENGTH u200)

;; Rarity Tiers
(define-constant RARITY-COMMON "common")
(define-constant RARITY-UNCOMMON "uncommon") 
(define-constant RARITY-RARE "rare")
(define-constant RARITY-EPIC "epic")
(define-constant RARITY-LEGENDARY "legendary")

;; STATE VARIABLES

(define-data-var protocol-fee uint u25)
(define-data-var next-item-id uint u1)
(define-data-var next-character-id uint u1)
(define-data-var next-realm-id uint u1)
(define-data-var total-prize-pool uint u0)

;; MAPS & DATA STRUCTURES  

;; Access Control
(define-map admins principal bool)

;; NFT Tokens
(define-non-fungible-token forge-item uint)
(define-non-fungible-token meta-character uint)

;; Core Data Structures
(define-map items
  { item-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-rating: uint,
    origin-realm: uint,
    xp-points: uint,
    level: uint,
    forge-time: uint
  }
)

(define-map characters
  { character-id: uint }
  {
    name: (string-ascii 50),
    level: uint,
    total-xp: uint,
    equipped-items: (list 5 uint),
    unlocked-realms: (list 10 uint),
    achievements: uint,
    creation-time: uint
  }
)

(define-map realms
  { realm-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    min-level-req: uint,
    active-players: uint,
    reward-multiplier: uint
  }
)

(define-map player-profiles
  { player: principal }
  {
    character-id: uint,
    total-score: uint,
    games-won: uint,
    total-earnings: uint,
    current-rank: uint,
    join-timestamp: uint
  }
)

;; VALIDATION FUNCTIONS

(define-private (is-valid-string (text (string-ascii 50)) (min-len uint) (max-len uint))
  (and 
    (>= (len text) min-len)
    (<= (len text) max-len)
    (> (len text) u0)
  )
)

(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (or 
    (is-eq rarity RARITY-COMMON)
    (is-eq rarity RARITY-UNCOMMON)
    (is-eq rarity RARITY-RARE)
    (is-eq rarity RARITY-EPIC)
    (is-eq rarity RARITY-LEGENDARY)
  )
)

(define-private (calculate-xp-for-level (level uint))
  (* level level BASE-XP-MULTIPLIER)
)

(define-private (can-level-up (current-xp uint) (current-level uint))
  (>= current-xp (calculate-xp-for-level (+ current-level u1)))
)

;; READ-ONLY FUNCTIONS

(define-read-only (is-admin (user principal))
  (default-to false (map-get? admins user))
)

(define-read-only (get-item-details (item-id uint))
  (map-get? items { item-id: item-id })
)

(define-read-only (get-character-details (character-id uint))
  (map-get? characters { character-id: character-id })
)

(define-read-only (get-realm-info (realm-id uint))
  (map-get? realms { realm-id: realm-id })
)

(define-read-only (get-player-profile (player principal))
  (map-get? player-profiles { player: player })
)

(define-read-only (get-protocol-stats)
  {
    total-items: (- (var-get next-item-id) u1),
    total-characters: (- (var-get next-character-id) u1),
    total-realms: (- (var-get next-realm-id) u1),
    prize-pool: (var-get total-prize-pool),
    protocol-fee: (var-get protocol-fee)
  }
)

;; ADMIN FUNCTIONS

(define-public (initialize-protocol)
  (begin
    (map-set admins tx-sender true)
    (ok "MetaForge Protocol Initialized")
  )
)

(define-public (add-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (map-set admins new-admin true)
    (ok true)
  )
)

(define-public (update-protocol-fee (new-fee uint))
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (<= new-fee u100) ERR-INVALID-INPUT)
    (var-set protocol-fee new-fee)
    (ok true)
  )
)

;; CORE GAMEPLAY FUNCTIONS

(define-public (forge-new-item 
    (name (string-ascii 50))
    (description (string-ascii 50))
    (rarity (string-ascii 20))
    (power-rating uint)
    (realm-id uint)
  )
  (let ((item-id (var-get next-item-id)))
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-valid-string name MIN-NAME-LENGTH MAX-NAME-LENGTH) ERR-INVALID-INPUT)
    (asserts! (is-valid-string description u1 MAX-DESCRIPTION-LENGTH) ERR-INVALID-INPUT)
    (asserts! (is-valid-rarity rarity) ERR-INVALID-RARITY)
    (asserts! (and (> power-rating u0) (<= power-rating u1000)) ERR-INVALID-INPUT)
    (asserts! (is-some (get-realm-info realm-id)) ERR-NOT-FOUND)

    (try! (nft-mint? forge-item item-id tx-sender))

    (map-set items { item-id: item-id } {
      name: name,
      description: description,
      rarity: rarity,
      power-rating: power-rating,
      origin-realm: realm-id,
      xp-points: u0,
      level: u1,
      forge-time: stacks-block-height
    })

    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

(define-public (create-character 
    (name (string-ascii 50))
    (starting-realm uint)
  )
  (let ((character-id (var-get next-character-id)))
    (asserts! (is-valid-string name MIN-NAME-LENGTH MAX-NAME-LENGTH) ERR-INVALID-INPUT)
    (asserts! (is-some (get-realm-info starting-realm)) ERR-NOT-FOUND)
    (asserts! (is-none (get-player-profile tx-sender)) ERR-ALREADY-EXISTS)

    (try! (nft-mint? meta-character character-id tx-sender))

    (map-set characters { character-id: character-id } {
      name: name,
      level: u1,
      total-xp: u0,
      equipped-items: (list),
      unlocked-realms: (list starting-realm),
      achievements: u0,
      creation-time: stacks-block-height
    })

    (map-set player-profiles { player: tx-sender } {
      character-id: character-id,
      total-score: u0,
      games-won: u0,
      total-earnings: u0,
      current-rank: u0,
      join-timestamp: stacks-block-height
    })

    (var-set next-character-id (+ character-id u1))
    (ok character-id)
  )
)

(define-public (create-realm
    (name (string-ascii 50))
    (description (string-ascii 50))
    (min-level uint)
    (reward-mult uint)
  )
  (let ((realm-id (var-get next-realm-id)))
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-valid-string name MIN-NAME-LENGTH MAX-NAME-LENGTH) ERR-INVALID-INPUT)
    (asserts! (is-valid-string description u1 MAX-DESCRIPTION-LENGTH) ERR-INVALID-INPUT)
    (asserts! (<= min-level MAX-LEVEL) ERR-INVALID-INPUT)
    (asserts! (and (> reward-mult u0) (<= reward-mult u500)) ERR-INVALID-INPUT)

    (map-set realms { realm-id: realm-id } {
      name: name,
      description: description,
      min-level-req: min-level,
      active-players: u0,
      reward-multiplier: reward-mult
    })

    (var-set next-realm-id (+ realm-id u1))
    (ok realm-id)
  )
)

;; PROGRESSION SYSTEM

(define-public (grant-xp (character-id uint) (xp-amount uint))
  (let (
      (character (unwrap! (get-character-details character-id) ERR-NOT-FOUND))
      (current-xp (get total-xp character))
      (current-level (get level character))
      (new-xp (+ current-xp xp-amount))
    )
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (> xp-amount u0) ERR-INVALID-INPUT)
    (asserts! (< current-level MAX-LEVEL) ERR-MAX-LIMIT-REACHED)

    (let (
        (new-level (if (can-level-up new-xp current-level) 
                      (+ current-level u1) 
                      current-level))
      )
      (map-set characters { character-id: character-id }
        (merge character {
          total-xp: new-xp,
          level: new-level
        })
      )
      (ok { level-up: (> new-level current-level), new-level: new-level })
    )
  )
)

(define-public (update-player-score (player principal) (score uint))
  (let ((profile (unwrap! (get-player-profile player) ERR-NOT-FOUND)))
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (<= score u100000) ERR-INVALID-INPUT)

    (map-set player-profiles { player: player }
      (merge profile {
        total-score: score,
        games-won: (+ (get games-won profile) u1)
      })
    )
    (ok true)
  )
)

;; ASSET TRANSFER FUNCTIONS

(define-public (transfer-item (item-id uint) (recipient principal))
  (let ((current-owner (unwrap! (nft-get-owner? forge-item item-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender current-owner) ERR-UNAUTHORIZED)
    (nft-transfer? forge-item item-id tx-sender recipient)
  )
)

(define-public (transfer-character (character-id uint) (recipient principal))
  (let ((current-owner (unwrap! (nft-get-owner? meta-character character-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender current-owner) ERR-UNAUTHORIZED)
    (nft-transfer? meta-character character-id tx-sender recipient)
  )
)

;; CONTRACT INITIALIZATION

;; Auto-initialize the deployer as the first admin
(map-set admins tx-sender true)