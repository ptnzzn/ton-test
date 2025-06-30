# TokenTradeMarket Smart Contract

🚀 **Decentralized Token Trading Platform on TON Blockchain**

A secure and efficient smart contract for peer-to-peer token trading on The Open Network (TON), built with Tact language.

## 📋 Features

- ✅ **Decentralized Trading**: Direct peer-to-peer token exchanges
- ✅ **Multi-Token Support**: Trade any Jetton with stable tokens
- ✅ **Admin Controls**: Pause/unpause, fee management, token allowlist
- ✅ **Security First**: Comprehensive access controls and validations
- ✅ **Gas Optimized**: Efficient message handling with explicit opcodes
- ✅ **Event Logging**: Complete transaction history and monitoring

## 🏗️ Architecture

### Core Components

- **TokenTradeMarket.tact**: Main contract with trading logic
- **Message Structs**: Optimized binary messages for all operations
- **Access Control**: Admin-only functions with proper validation
- **Fee System**: Configurable trading fees with basis points

### Message Types

| Opcode | Message | Description |
|--------|---------|-------------|
| `0x01` | UpdateFeeRate | Update trading fee percentage |
| `0x02` | UpdateAllowedStable | Add/remove allowed stable tokens |
| `0x03` | CreateOrder | Create new sell order |
| `0x04` | CancelOrder | Cancel existing order |
| `0x05` | BuyOrder | Purchase tokens from order |
| `0x06` | PauseContract | Emergency pause |
| `0x07` | UnpauseContract | Resume operations |

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn
- TON wallet (Tonkeeper recommended)
- TON API key from [@tonapibot](https://t.me/tonapibot)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd ton-test

# Install dependencies
npm install

# Setup environment and wallet
npm run setup
```

### Configuration

1. **Edit `.env` file** with your actual values:
```env
TON_API_KEY=your_api_key_here
ADMIN_WALLET=your_admin_wallet_address
BACKEND_SIGNER=your_backend_signer_address
FEE_RECEIVER=your_fee_receiver_address
FEE_RATE=100  # 1% = 100 basis points
```

2. **Get testnet TON** from [@testgiver_ton_bot](https://t.me/testgiver_ton_bot)

### Deployment

```bash
# Deploy to testnet
npm run deploy:testnet

# Verify deployment
npm run check:testnet

# Deploy to mainnet (after thorough testing)
npm run deploy:mainnet
```

## 📚 Available Scripts

| Script | Description |
|--------|-------------|
| `npm run setup` | Create .env + generate wallet |
| `npm run create-env` | Create .env file only |
| `npm run generate-wallet` | Generate new wallet only |
| `npm run compile` | Compile Tact contract |
| `npm run deploy:testnet` | Compile + deploy to testnet |
| `npm run deploy:mainnet` | Compile + deploy to mainnet |
| `npm run check:testnet` | Check contract on testnet |
| `npm run check:mainnet` | Check contract on mainnet |
| `npm test` | Run automated contract tests |
| `npm run test:contract` | Run contract functionality tests |
| `npm run interact` | Interactive contract testing tool |

## 🔧 Usage Examples

### Admin Operations

```typescript
// Add allowed stable token
await contract.send(sender, { value: toNano('0.05') }, {
  $$type: 'UpdateAllowedStable',
  stableAddress: Address.parse('EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c'),
  allowed: true
});

// Update fee rate to 2%
await contract.send(sender, { value: toNano('0.05') }, {
  $$type: 'UpdateFeeRate',
  feeRate: 200n  // 200 basis points = 2%
});

// Pause contract
await contract.send(sender, { value: toNano('0.05') }, {
  $$type: 'PauseContract'
});
```

### Trading Operations

```typescript
// Create sell order
await contract.send(seller, { value: toNano('0.1') }, {
  $$type: 'CreateOrder',
  id: 1n,
  jettonAddress: Address.parse('jetton_address'),
  jettonAmount: toNano('100'),
  stableAddress: Address.parse('stable_address'),
  stableAmount: toNano('50')
});

// Buy from order
await contract.send(buyer, { value: toNano('0.1') }, {
  $$type: 'BuyOrder',
  id: 1n
});

// Cancel order
await contract.send(seller, { value: toNano('0.05') }, {
  $$type: 'CancelOrder',
  id: 1n
});
```

## 🔍 Contract Information

### Getter Functions

- `getContractInfo()`: Get admin, fee rate, pause status
- `getSellOrder(id)`: Get specific order details
- `getIsAllowedStable(address)`: Check if token is allowed
- `getNextOrderId()`: Get next available order ID

### State Variables

- `adminWallet`: Contract administrator
- `backendSigner`: Backend service signer
- `feeReceiver`: Fee collection address
- `feeRate`: Trading fee in basis points
- `isPaused`: Emergency pause status
- `sellOrders`: Active sell orders mapping
- `allowedStables`: Allowed stable token addresses

## 🛡️ Security Features

- **Access Control**: Admin-only functions with sender validation
- **Emergency Pause**: Immediate trading halt capability
- **Input Validation**: Comprehensive parameter checking
- **Reentrancy Protection**: Safe external calls
- **Fee Limits**: Configurable maximum fee rates

## 🧪 Testing

### Automated Contract Testing
```bash
# Run comprehensive contract tests
npm test
# or
npm run test:contract

# Interactive contract testing
npm run interact
```

### Test Features
- **Contract Info Retrieval**: Test getting admin, fee rate, pause status
- **Balance Checking**: Verify contract TON balance
- **Stable Token Validation**: Check allowed stable tokens
- **Order Management**: Test order creation, cancellation, and buying
- **Interactive Mode**: Manual contract interaction with guided prompts

### Prerequisites for Testing
1. Deploy contract to testnet first:
   ```bash
   npm run deploy:testnet
   ```

2. Update `.env` with deployed contract address:
   ```env
   CONTRACT_ADDRESS=your_deployed_contract_address
   ```

3. Run tests:
   ```bash
   npm test  # Automated tests
   npm run interact  # Interactive testing
   ```

## 📖 Documentation

- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - Complete deployment instructions
- [Tact Documentation](https://docs.tact-lang.org/) - Tact language reference
- [TON Documentation](https://docs.ton.org/) - TON blockchain docs
- [Blueprint](https://github.com/ton-org/blueprint) - TON development framework

## 🔗 Useful Links

- **Testnet Explorer**: [testnet.tonviewer.com](https://testnet.tonviewer.com/)
- **Mainnet Explorer**: [tonviewer.com](https://tonviewer.com/)
- **TON API Bot**: [@tonapibot](https://t.me/tonapibot)
- **Testnet Faucet**: [@testgiver_ton_bot](https://t.me/testgiver_ton_bot)
- **Tonkeeper Wallet**: [tonkeeper.com](https://tonkeeper.com/)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Deployment Guide](./DEPLOYMENT_GUIDE.md)
2. Review the [troubleshooting section](./DEPLOYMENT_GUIDE.md#-troubleshooting)
3. Open an issue on GitHub

---

**Built with ❤️ for the TON ecosystem**