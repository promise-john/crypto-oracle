# CryptoOracle - Intelligent Bitcoin Price Prediction Markets

[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange)](https://stacks.co/)
[![License](https://img.shields.io/badge/License-ISC-green)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-brightgreen)](https://vitest.dev/)

> Advanced decentralized prediction platform for Bitcoin price movements built on Stacks blockchain

## 📖 Overview

CryptoOracle revolutionizes cryptocurrency price prediction through a sophisticated smart contract ecosystem. Users can leverage their market insights by staking STX tokens on Bitcoin's price trajectory, earning rewards based on accuracy and stake proportions. The protocol features dynamic market creation, oracle-verified price settlements, automated reward calculations, and robust security mechanisms.

### Key Features

- 🎯 **Decentralized Prediction Markets** - Trustless Bitcoin price prediction platform
- 💰 **STX Token Staking** - Stake STX on price movements (up/down)
- 🏆 **Proportional Rewards** - Earn rewards based on accuracy and stake size
- 🔮 **Oracle Integration** - Verified price settlements for market resolution
- 🛡️ **Security First** - Comprehensive error handling and access controls
- 📊 **Transparent Economics** - Open-source protocol with clear fee structure

## 🏗️ Architecture

### Smart Contract Components

#### Core Data Structures

- **Markets Map**: Stores market lifecycle data including prices, stakes, and resolution status
- **User Predictions Map**: Tracks individual participant positions and claim status
- **Configuration Variables**: Oracle address, minimum stakes, and fee parameters

#### Primary Functions

1. **Market Creation** - Administrative function to initialize new prediction markets
2. **Prediction Placement** - User function to stake STX on price direction
3. **Oracle Settlement** - Authorized price resolution mechanism
4. **Reward Distribution** - Automated payout calculation and distribution

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development tool
- [Node.js](https://nodejs.org/) (v16+) - For testing environment
- [Stacks Wallet](https://wallet.hiro.so/) - For mainnet interactions

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/promise-john/crypto-oracle.git
   cd crypto-oracle
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract syntax**

   ```bash
   clarinet check
   ```

4. **Run test suite**

   ```bash
   npm test
   ```

## 🧪 Testing

The project includes comprehensive test coverage using Vitest and Clarinet SDK.

### Run Tests

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```text
tests/
└── crypto-oracle.test.ts    # Main contract test suite
```

## 🔧 Development

### Contract Compilation

```bash
# Check contract syntax and types
clarinet check

# Format contracts
clarinet fmt

# Interactive REPL
clarinet console
```

### Local Development Network

```bash
# Start local Stacks blockchain
clarinet integrate

# Deploy to local network
clarinet deploy --devnet
```

## 📋 Contract Interface

### Public Functions

#### Market Management

```clarity
;; Create new prediction market
(define-public (create-market (start-price uint) (start-block uint) (end-block uint)))

;; Place prediction on market
(define-public (make-prediction (market-id uint) (prediction (string-ascii 4)) (stake uint)))

;; Resolve market with oracle price
(define-public (resolve-market (market-id uint) (end-price uint)))

;; Claim winnings from resolved market
(define-public (claim-winnings (market-id uint)))
```

#### Administrative Functions

```clarity
;; Update oracle address
(define-public (set-oracle-address (new-address principal)))

;; Set minimum stake requirement
(define-public (set-minimum-stake (new-minimum uint)))

;; Adjust protocol fee percentage
(define-public (set-fee-percentage (new-fee uint)))

;; Withdraw accumulated fees
(define-public (withdraw-fees (amount uint)))
```

### Read-Only Functions

```clarity
;; Get market information
(define-read-only (get-market (market-id uint)))

;; Get user prediction data
(define-read-only (get-user-prediction (market-id uint) (user principal)))

;; Check contract balance
(define-read-only (get-contract-balance))

;; View platform configuration
(define-read-only (get-platform-config))
```

## 💼 Economic Model

### Staking Mechanics

- **Minimum Stake**: 1 STX (configurable)
- **Protocol Fee**: 2% (configurable)
- **Reward Distribution**: Proportional to stake among winners

### Example Scenario

1. Market created for Bitcoin price prediction
2. Users stake STX on "up" or "down" predictions
3. Oracle resolves market with final price
4. Winning participants claim proportional rewards
5. Protocol collects 2% fee from total winnings

## 🔐 Security Features

### Access Controls

- **Contract Owner**: Administrative functions restricted
- **Oracle Authority**: Only authorized oracle can resolve markets
- **Claim Protection**: Prevents double-claiming of rewards

### Error Handling

- Comprehensive error codes for all failure scenarios
- Input validation for all public functions
- Balance and timing checks before state changes

### Error Codes

| Code | Description |
|------|-------------|
| u100 | Unauthorized access denied |
| u101 | Resource does not exist |
| u102 | Malformed prediction data |
| u103 | Market trading window expired |
| u104 | Rewards previously claimed |
| u105 | Inadequate STX balance |
| u106 | Invalid function arguments |

## 🌐 Deployment

### Network Configuration

```toml
# Devnet settings
[settings.devnet]
host = "127.0.0.1"
port = 20443

# Testnet settings  
[settings.testnet]
host = "stacks-node-api.testnet.stacks.co"
port = 443

# Mainnet settings
[settings.mainnet]
host = "stacks-node-api.mainnet.stacks.co"
port = 443
```

### Deployment Commands

```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## 📊 Monitoring & Analytics

### Contract Metrics

- Total markets created
- Active prediction volume
- User participation rates
- Protocol fee accumulation

### Integration Examples

```javascript
// Query market data
const market = await contract.callReadOnlyFunction({
  contractAddress: 'SP123...',
  contractName: 'crypto-oracle',
  functionName: 'get-market',
  functionArgs: [uintCV(1)]
});
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes and add tests
4. Ensure all tests pass (`npm test`)
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open Pull Request

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.
