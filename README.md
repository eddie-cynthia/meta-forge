# MetaForge Protocol

> Revolutionary Web3 Gaming Infrastructure for the Next Generation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity](https://img.shields.io/badge/Language-Clarity-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Blockchain-Stacks-purple.svg)](https://stacks.co/)

MetaForge transforms traditional gaming through blockchain technology, creating a unified ecosystem where digital assets transcend individual games. Players can forge legendary items, evolve persistent characters, and compete in interconnected virtual worlds while earning real economic value.

## 🎯 Key Innovations

- **Cross-Platform Asset Portability** - Items work across multiple games
- **Algorithmic Rarity Engine** - Dynamic scarcity based on player behavior  
- **Skill-Based Token Economics** - Rewards tied to gameplay mastery
- **Community-Governed Tournaments** - Player-driven competitive events
- **Persistent Character Evolution** - Characters grow across game boundaries

Built on Stacks for Bitcoin-secured transactions with lightning-fast gameplay.

## 🏗️ Architecture Overview

MetaForge Protocol consists of several interconnected components:

### Core NFT Assets

- **Forge Items** - Tradeable game items with cross-platform compatibility
- **Meta Characters** - Persistent player avatars that evolve across realms

### Game Mechanics

- **Realms** - Individual game worlds with unique mechanics
- **Experience System** - Skill-based progression with algorithmic leveling
- **Rarity Tiers** - Five-tier rarity system (Common → Legendary)

### Economic Model

- **Protocol Fees** - Configurable revenue sharing mechanism
- **Prize Pools** - Community-driven tournament rewards
- **Asset Trading** - Decentralized marketplace for items and characters

## 📋 Contract Interface

### Core Functions

#### Character Management

```clarity
;; Create a new character
(define-public (create-character (name (string-ascii 50)) (starting-realm uint)))

;; Grant experience points
(define-public (grant-xp (character-id uint) (xp-amount uint)))

;; Transfer character ownership
(define-public (transfer-character (character-id uint) (recipient principal)))
```

#### Item Forging

```clarity
;; Forge a new item
(define-public (forge-new-item 
  (name (string-ascii 50))
  (description (string-ascii 50))
  (rarity (string-ascii 20))
  (power-rating uint)
  (realm-id uint)))

;; Transfer item ownership
(define-public (transfer-item (item-id uint) (recipient principal)))
```

#### Realm Administration

```clarity
;; Create a new realm
(define-public (create-realm
  (name (string-ascii 50))
  (description (string-ascii 50))
  (min-level uint)
  (reward-mult uint)))
```

### Read-Only Functions

```clarity
;; Get item details
(define-read-only (get-item-details (item-id uint)))

;; Get character information
(define-read-only (get-character-details (character-id uint)))

;; Get realm information
(define-read-only (get-realm-info (realm-id uint)))

;; Get player profile
(define-read-only (get-player-profile (player principal)))

;; Get protocol statistics
(define-read-only (get-protocol-stats))
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet CLI](https://github.com/hirosystems/clarinet) >= 2.0
- [Node.js](https://nodejs.org/) >= 18.0
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/eddie-cynthia/meta-forge.git
   cd meta-forge
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Development Workflow

#### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

#### Contract Validation

```bash
# Check contract syntax
clarinet check

# Deploy to local testnet
clarinet integrate

# Console interaction
clarinet console
```

## 🧪 Testing

The project uses Vitest with Clarinet SDK for comprehensive testing:

```typescript
import { describe, expect, it } from "vitest";

describe("MetaForge Protocol", () => {
  it("should create a new character", () => {
    const { result } = simnet.callPublicFn(
      "meta-forge",
      "create-character",
      [Cl.stringAscii("Hero"), Cl.uint(1)],
      deployer
    );
    expect(result).toBeOk(Cl.uint(1));
  });
});
```

## 📊 Game Mechanics

### Rarity System

| Tier | Identifier | Drop Rate | Power Multiplier |
|------|------------|-----------|------------------|
| Common | `common` | 60% | 1.0x |
| Uncommon | `uncommon` | 25% | 1.5x |
| Rare | `rare` | 10% | 2.0x |
| Epic | `epic` | 4% | 3.0x |
| Legendary | `legendary` | 1% | 5.0x |

### Experience System

- **Base XP Multiplier**: 100
- **Level Formula**: `level² × BASE_XP_MULTIPLIER`
- **Max Level**: 100
- **Auto Level-Up**: Triggered when sufficient XP is accumulated

### Protocol Economics

- **Default Protocol Fee**: 2.5%
- **Max Fee Cap**: 10%
- **Revenue Distribution**: Community treasury, development, rewards

## 🔐 Security Features

### Access Control

- **Admin-only functions** for critical operations
- **Ownership verification** for asset transfers
- **Input validation** for all user data

### Error Handling

- Comprehensive error codes (100-107)
- Safe unwrapping with meaningful error messages
- Bounds checking for all numeric inputs

### Data Integrity

- Immutable game history
- Cryptographic ownership proofs
- Atomic transaction guarantees

## 🌐 Deployment

### Testnet Deployment

```bash
# Deploy to Stacks testnet
clarinet deployments generate --testnet

# Apply deployment
clarinet deployments apply -p deployments/testnet.devnet-plan.yaml
```

### Mainnet Deployment

```bash
# Generate mainnet deployment plan
clarinet deployments generate --mainnet

# Review and apply
clarinet deployments apply -p deployments/mainnet.devnet-plan.yaml
```

## 📈 Roadmap

### Phase 1: Core Infrastructure ✅

- [x] Basic NFT implementation
- [x] Character creation system
- [x] Item forging mechanics
- [x] Experience progression

### Phase 2: Advanced Features 🚧

- [ ] Cross-realm asset migration
- [ ] Tournament system
- [ ] Marketplace integration
- [ ] Governance mechanisms

### Phase 3: Ecosystem Expansion 📋

- [ ] Multi-game integration APIs
- [ ] Developer SDK
- [ ] Mobile companion app
- [ ] Advanced analytics dashboard

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Standards

- Follow Clarity best practices
- Write comprehensive tests
- Document all public functions
- Use meaningful variable names

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

- Built on [Stacks](https://stacks.co/) blockchain
- Powered by [Clarity](https://clarity-lang.org/) smart contracts
- Testing with [Clarinet](https://github.com/hirosystems/clarinet)
