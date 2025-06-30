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
| `0x08` | SetJettonWalletCode | Set Jetton wallet code for tokens |
| `0x946a98b6` | Deploy | Contract deployment message |
| `0xf8a7ea5` | JettonTransfer | Standard Jetton transfer |
| `0x7362d09c` | JettonTransferNotification | Jetton transfer notification |

## 📋 Contract Details

### TokenTradeMarket Contract

The main smart contract `TokenTradeMarket.tact` implements a comprehensive decentralized trading platform with the following key features:

#### Contract State Variables

```tact
contract TokenTradeMarket {
    // Admin configuration
    adminWallet: Address;           // Contract administrator
    backendSigner: Address;         // Backend service signer
    feeReceiver: Address;           // Fee collection address
    feeRate: Int;                   // Trading fee (basis points)
    
    // Contract status
    isPaused: Bool;                 // Emergency pause state
    
    // Token management
    allowedStableTokens: map<Address, Bool>;     // Allowed stable tokens
    jettonWalletCodes: map<Address, Cell>;       // Jetton wallet codes
    validJettonWallets: map<Address, Bool>;      // Valid wallet validation
    
    // Trading data
    sellOrders: map<Int, SellOrder>;             // Active sell orders
}
```

#### Core Data Structures

**SellOrder Struct:**
```tact
struct SellOrder {
    seller: Address;        // Order creator
    token: Address;         // Token being sold
    amount: Int;           // Token amount
    price: Int;            // Price per token
    minBuyPrice: Int;      // Minimum purchase amount
    active: Bool;          // Order status
}
```

**JettonWalletData Struct:**
```tact
struct JettonWalletData {
    balance: Int as coins;
    ownerAddress: Address;
    jettonMasterAddress: Address;
    jettonWalletCode: Cell;
}
```

#### Gas Management Constants

```tact
const GAS_FOR_JETTON_TRANSFER: Int = ton("0.1");  // Gas for Jetton transfers
const GAS_FOR_FORWARD: Int = ton("0.05");         // Gas for forwarding
const MIN_TONS_FOR_STORAGE: Int = ton("0.01");    // Minimum storage fee
```

#### Key Functions

**Administrative Functions:**
- `receive(msg: PauseContract)` - Emergency pause
- `receive(msg: UnpauseContract)` - Resume operations
- `receive(msg: UpdateFeeRate)` - Update trading fees
- `receive(msg: UpdateAllowedStable)` - Manage stable tokens
- `receive(msg: SetJettonWalletCode)` - Set Jetton wallet codes

**Trading Functions:**
- `receive(msg: CreateOrder)` - Create new sell orders
- `receive(msg: CancelOrder)` - Cancel existing orders
- `receive(msg: BuyOrder)` - Purchase from orders
- `receive(msg: JettonTransferNotification)` - Handle incoming transfers

**Utility Functions:**
- `calculateJettonWalletAddress()` - Calculate Jetton wallet addresses
- `bounced(src: bounced<JettonTransfer>)` - Handle failed transfers

#### Security Features

1. **Access Control**: Admin-only functions with sender validation
2. **Jetton Wallet Validation**: Comprehensive wallet address verification
3. **Gas Management**: Optimized gas usage with separate gas modes
4. **Reentrancy Protection**: Safe external call patterns
5. **Input Validation**: Comprehensive parameter checking
6. **Emergency Controls**: Pause/unpause functionality

#### Trading Flow

1. **Order Creation**: Sellers create orders with token, amount, and price
2. **Order Validation**: Contract validates token support and parameters
3. **Purchase Execution**: Buyers purchase with automatic fee calculation
4. **Token Transfer**: Secure Jetton transfers with proper gas management
5. **Fee Distribution**: Automatic fee collection and seller payment
6. **Order Updates**: Atomic order state updates to prevent race conditions

#### Error Handling

- **Bounced Messages**: Proper handling of failed Jetton transfers
- **Validation Errors**: Comprehensive input validation with clear error messages
- **Security Checks**: Multiple layers of security validation
- **Gas Failures**: Graceful handling of insufficient gas scenarios

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

- `getAdminWallet()`: Get contract administrator address
- `getBackendSigner()`: Get backend signer address
- `getFeeReceiver()`: Get fee receiver address
- `getFeeRate()`: Get trading fee rate in basis points
- `getIsPaused()`: Get contract pause status
- `getOrderInfo(id)`: Get specific order details
- `isJettonSupported(address)`: Check if jetton is supported
- `getContractJettonWallet(address)`: Get contract's jetton wallet address

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