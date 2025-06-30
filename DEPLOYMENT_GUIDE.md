# 🚀 TokenTradeMarket Smart Contract Deployment Guide

## 📋 Table of Contents
- [System Requirements](#system-requirements)
- [Environment Setup](#environment-setup)
- [Project Configuration](#project-configuration)
- [Testnet Deployment](#testnet-deployment)
- [Mainnet Deployment](#mainnet-deployment)
- [Testing and Interaction](#testing-and-interaction)
- [Troubleshooting](#troubleshooting)

## 🔧 System Requirements

### Software Requirements
- **Node.js**: >= 18.0.0
- **npm**: >= 8.0.0
- **Git**: Latest version
- **TON Wallet**: Tonkeeper, TON Wallet, or MyTonWallet

### Check versions
```bash
node --version
npm --version
git --version
```

## 🛠️ Environment Setup

### 1. Clone and setup project
```bash
# Clone project (if not already done)
git clone <your-repo-url>
cd ton-test

# Install dependencies
npm install

# Install Blueprint globally
npm install -g @ton/blueprint
```

### 2. Create TON Wallet

#### Testnet Wallet
```bash
# Use the automated script (recommended)
npm run generate-wallet

# Or use TON CLI to create testnet wallet
npx @ton/sandbox-cli wallet create

# Or use Tonkeeper with testnet mode
# Settings > Developer Mode > Enable Testnet
```

The `generate-wallet` script will:
- Generate a new 24-word mnemonic
- Create a V4 wallet contract
- Display the wallet address
- Show current balance (0 TON for new wallets)

#### Get testnet TON
- Visit: https://t.me/testgiver_ton_bot

### 3. Get API Key
```bash
# Telegram bot to get API key
# Visit: https://t.me/tonapibot
# Send /start and follow instructions
```

## 🚀 Quick Start Scripts

This project includes convenient npm scripts for common tasks:

```bash
# Setup (first time only)
npm run setup              # Create .env + generate wallet
npm run create-env         # Create .env file only
npm run generate-wallet    # Generate new wallet only

# Development
npm run compile           # Compile Tact contract
npm run deploy:testnet    # Compile + deploy to testnet
npm run deploy:mainnet    # Compile + deploy to mainnet

# Verification
npm run check:testnet     # Check contract on testnet
npm run check:mainnet     # Check contract on mainnet
```

## ⚙️ Project Configuration

### 1. Create .env file
```bash
# Use the automated script (recommended)
npm run create-env

# Or create manually on Windows
echo. > .env

# Or on Unix/Linux/Mac
touch .env
```

The script will create a `.env` file with this template:
```env
# TON API Configuration
TON_API_KEY=your_api_key_here

# Wallet Addresses (replace with your actual addresses)
ADMIN_WALLET=your_admin_wallet_address
BACKEND_SIGNER=your_backend_signer_address
FEE_RECEIVER=your_fee_receiver_address

# Contract Configuration
FEE_RATE=100

# Network Configuration
NETWORK=testnet

# Contract Address (will be filled after deployment)
CONTRACT_ADDRESS=
```

### 2. Update blueprint.config.ts
```typescript
import { Config } from '@ton/blueprint';

export const config: Config = {
    network: {
        endpoint: 'https://testnet.toncenter.com/api/v2/jsonRPC',
        type: 'testnet',
        version: 'v2',
        key: process.env.TON_API_KEY || 'your_api_key_here'
    },
};
```

### 3. Update deploy script
```typescript
// scripts/deploy.ts
import { toNano, Address } from '@ton/core';
import { TokenTradeMarket } from '../build/TokenTradeMarket/tact_TokenTradeMarket';
import { NetworkProvider } from '@ton/blueprint';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export async function run(provider: NetworkProvider) {
    console.log('🚀 Starting deployment...');
    
    // Validate environment variables
    const adminWallet = process.env.ADMIN_WALLET;
    const backendSigner = process.env.BACKEND_SIGNER;
    const feeReceiver = process.env.FEE_RECEIVER;
    const feeRate = process.env.FEE_RATE || '100';
    
    if (!adminWallet || !backendSigner || !feeReceiver) {
        throw new Error('❌ Missing required environment variables');
    }
    
    console.log('📋 Deployment parameters:');
    console.log(`   Admin Wallet: ${adminWallet}`);
    console.log(`   Backend Signer: ${backendSigner}`);
    console.log(`   Fee Receiver: ${feeReceiver}`);
    console.log(`   Fee Rate: ${feeRate}% (${BigInt(feeRate)} basis points)`);
    
    // Initialize contract
    const tokenTradeMarket = provider.open(await TokenTradeMarket.fromInit(
        Address.parse(adminWallet),
        Address.parse(backendSigner),
        Address.parse(feeReceiver),
        BigInt(feeRate)
    ));
    
    console.log(`📍 Contract address: ${tokenTradeMarket.address}`);
    
    // Check if already deployed
    const isDeployed = await provider.isContractDeployed(tokenTradeMarket.address);
    if (isDeployed) {
        console.log('⚠️  Contract already deployed!');
        return;
    }
    
    // Deploy contract
    console.log('📤 Sending deployment transaction...');
    await tokenTradeMarket.send(
        provider.sender(),
        {
            value: toNano('0.1'), // 0.1 TON for deployment
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );
    
    // Wait for deployment
    console.log('⏳ Waiting for deployment confirmation...');
    await provider.waitForDeploy(tokenTradeMarket.address);
    
    console.log('✅ Contract deployed successfully!');
    console.log(`📍 Contract Address: ${tokenTradeMarket.address}`);
    console.log(`🔗 Testnet Explorer: https://testnet.tonviewer.com/${tokenTradeMarket.address}`);
    console.log(`🔗 Mainnet Explorer: https://tonviewer.com/${tokenTradeMarket.address}`);
    
    // Verify deployment
    const adminWallet = await tokenTradeMarket.getGetAdminWallet();
    const feeRate = await tokenTradeMarket.getGetFeeRate();
    const isPaused = await tokenTradeMarket.getGetIsPaused();
    console.log('📊 Contract Info:');
    console.log(`   Admin: ${adminWallet}`);
    console.log(`   Fee Rate: ${feeRate}`);
    console.log(`   Is Paused: ${isPaused}`);
}
```

## 🧪 Testnet Deployment

### 1. Quick Setup (First Time)
```bash
# Create .env file and generate wallet
npm run setup

# Edit .env file with your values
# Add TON_API_KEY, update wallet addresses
```

### 2. Compile contract
```bash
npm run compile
```

### 3. Deploy to testnet
```bash
npm run deploy:testnet
```

### 4. Verify deployment
```bash
# Check contract status
npm run check:testnet

# Or check on testnet explorer
# https://testnet.tonviewer.com/[contract-address]
```

## 🌐 Mainnet Deployment

### ⚠️ Pre-deployment Checklist

- [ ] ✅ Fully tested on testnet
- [ ] ✅ Code thoroughly reviewed
- [ ] ✅ Sufficient TON in wallet (at least 1 TON)
- [ ] ✅ Seed phrase safely backed up
- [ ] ✅ All wallet addresses verified
- [ ] ✅ Reasonable fee rate (not too high)

### 1. Update config for mainnet
```typescript
// blueprint.config.ts
export const config: Config = {
    network: {
        endpoint: 'https://toncenter.com/api/v2/jsonRPC',
        type: 'mainnet',
        version: 'v2',
        key: process.env.TON_API_KEY
    },
};
```

### 2. Deploy
```bash
# Deploy to mainnet (includes compilation)
npm run deploy:mainnet

# Verify deployment
npm run check:mainnet

# Monitor transaction
# Use transaction hash to track
```

### 3. Post-deployment setup
```bash
# Run setup script after deployment
npx blueprint run setup --mainnet
```

## 🔧 Testing and Interaction

### Quick Testing Commands

```bash
# Run automated contract tests
npm test

# Interactive contract testing
npm run interact

# Test specific contract functions
npm run test:contract
```

### Automated Testing Features

The project includes comprehensive testing utilities in the `utils/` directory:

#### 1. Contract Functionality Tests (`utils/TestContract/`)
- **Contract Info Retrieval**: Tests getting admin wallet, fee rate, and pause status
- **Balance Verification**: Checks contract TON balance
- **Stable Token Validation**: Verifies allowed stable token configurations
- **Order Management**: Tests order ID generation and order retrieval
- **Error Handling**: Validates proper error responses

#### 2. Interactive Testing Tool (`utils/InteractContract/`)
- **Admin Operations**: Pause/unpause contract, update fee rates
- **Token Management**: Add/remove allowed stable tokens
- **Order Operations**: Create, cancel, and buy orders
- **Status Monitoring**: Real-time contract status checking
- **Message Preparation**: Generates proper message formats for transactions

### Testing Prerequisites

1. **Deploy Contract First**:
   ```bash
   npm run deploy:testnet
   ```

2. **Update Environment**:
   ```env
   # Add to .env file
   CONTRACT_ADDRESS=your_deployed_contract_address
   ```

3. **Verify Setup**:
   ```bash
   # Check if contract is accessible
   npm test
   ```

### Testing Workflow

#### Step 1: Automated Testing
```bash
# Run comprehensive tests
npm test
```

Expected output:
```
🧪 Starting Contract Testing...
📍 Testing contract at: EQC...

📊 Test 1: Getting contract information...
✅ Contract Info Retrieved:
   Admin Wallet: EQC...
   Fee Rate: 20 basis points (0.2%)
   Is Paused: false

💰 Test 2: Checking contract balance...
✅ Contract Balance: 100000000 nanoTON (0.1 TON)

🪙 Test 3: Checking stable token allowance...
✅ Dummy stable token allowed: false

🔢 Test 4: Getting next order ID...
✅ Next Order ID: 1

📋 Test 5: Checking sell order (ID: 1)...
✅ No sell order found with ID 1 (expected for new contract)

🎉 Contract testing completed!
```

#### Step 2: Interactive Testing
```bash
# Start interactive mode
npm run interact
```

Interactive menu:
```
📋 Available Actions:
1. Pause Contract (Admin only)
2. Unpause Contract (Admin only)
3. Update Fee Rate (Admin only)
4. Add Allowed Stable Token (Admin only)
5. Remove Allowed Stable Token (Admin only)
6. Create Sell Order
7. Cancel Sell Order
8. Buy Order
9. Check Contract Status
0. Exit

Select an action (0-9):
```

### Testing Scenarios

#### Scenario 1: Admin Operations Testing
```bash
# Test admin functions
npm run interact
# Select option 1 (Pause Contract)
# Select option 2 (Unpause Contract)
# Select option 3 (Update Fee Rate)
```

#### Scenario 2: Trading Operations Testing
```bash
# Test trading functions
npm run interact
# Select option 6 (Create Sell Order)
# Select option 8 (Buy Order)
# Select option 7 (Cancel Sell Order)
```

#### Scenario 3: Status Monitoring
```bash
# Monitor contract status
npm run interact
# Select option 9 (Check Contract Status)
```

### Advanced Testing

#### 1. Custom Testing with Contract Address
```bash
# Test specific contract address
npm test -- EQC1234567890abcdef...

# Interactive testing with specific address
npm run interact -- EQC1234567890abcdef...
```

#### 2. Environment-based Testing
```bash
# Test with different environments
CONTRACT_ADDRESS=EQC... npm test
CONTRACT_ADDRESS=EQC... npm run interact
```

#### 3. Custom Testing Script
```typescript
// utils/custom-test.ts
import { Address } from '@ton/core';
import { TokenTradeMarket } from '../build/TokenTradeMarket/tact_TokenTradeMarket';
import { NetworkProvider } from '@ton/blueprint';

export async function customTest(provider: NetworkProvider, contractAddress: string) {
    const contract = provider.open(TokenTradeMarket.fromAddress(Address.parse(contractAddress)));
    
    // Your custom test logic here
    console.log('🔧 Running custom tests...');
    
    // Example: Test specific functionality
    const adminWallet = await contract.getGetAdminWallet();
    const feeRate = await contract.getGetFeeRate();
    const isPaused = await contract.getGetIsPaused();
    console.log('Contract Info:', { adminWallet, feeRate, isPaused });
}
```

### Testing Best Practices

#### 1. Pre-Testing Checklist
- ✅ Contract deployed successfully
- ✅ `.env` file contains correct `CONTRACT_ADDRESS`
- ✅ Wallet has sufficient TON for gas fees
- ✅ Network connection is stable

#### 2. Testing Order
1. **Basic Functionality**: Run `npm test` first
2. **Admin Operations**: Test pause/unpause, fee updates
3. **Trading Operations**: Test order creation, buying, cancellation
4. **Edge Cases**: Test with invalid inputs, insufficient funds

#### 3. Gas Fee Considerations
- Each test transaction requires gas fees (~0.01-0.05 TON)
- Ensure wallet has sufficient balance before testing
- Monitor gas usage during interactive testing

### Troubleshooting

#### Common Issues

**1. "Contract address required" Error**
```bash
# Solution: Set CONTRACT_ADDRESS in .env
echo "CONTRACT_ADDRESS=your_contract_address" >> .env
```

**2. "Insufficient funds" Error**
```bash
# Solution: Add TON to your wallet
# Check balance first
npm run interact
# Select option 9 to check contract status
```

**3. "Contract not found" Error**
```bash
# Solution: Verify contract address
# Check if contract is deployed correctly
npm run check:testnet
```

**4. Network Connection Issues**
```bash
# Solution: Check network connectivity
# Try different RPC endpoint if needed
```

#### Debug Mode
```bash
# Enable debug logging
DEBUG=true npm test
DEBUG=true npm run interact
```

### Testing Checklist

- [ ] Contract deployed successfully
- [ ] Environment variables configured
- [ ] Automated tests pass
- [ ] Admin functions work correctly
- [ ] Trading operations function properly
- [ ] Error handling works as expected
- [ ] Gas fees are reasonable
- [ ] Contract state updates correctly


### 3. Run scripts
```bash
# Check contract
npx blueprint run check --testnet [contract_address]

# Interact with contract
npx blueprint run interact --testnet [contract_address] pause
npx blueprint run interact --testnet [contract_address] update-fee 200
npx blueprint run interact --testnet [contract_address] add-stable [token_address]
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Insufficient balance"
```bash
# Check wallet balance
npx blueprint run balance

# Add more TON (testnet)
curl -X POST https://testnet.toncenter.com/api/v2/sendBoc \
  -H "Content-Type: application/json" \
  -d '{"boc":"your_boc_here"}'
```

#### 2. "Contract not found"
```bash
# Verify contract address
npx blueprint run verify --testnet --address [contract_address]

# Check deployment status
npx blueprint run status --testnet [contract_address]
```

#### 3. "Transaction failed"
```bash
# Debug transaction
npx blueprint run debug --testnet [tx_hash]

# Check gas usage
npx blueprint run gas-estimate --testnet
```

#### 4. "Invalid address"
```bash
# Validate address
node -e "console.log(require('@ton/core').Address.parse('your_address'))"
```

#### 5. "Network timeout"
```bash
# Try with different endpoint
# Or increase timeout in config
```

### Debug tools

```bash
# Enable debug mode
export DEBUG=blueprint:*

# Verbose logging
npx blueprint run deploy --testnet --verbose

# Dry run (simulation)
npx blueprint run deploy --testnet --dry-run

# View transaction details
npx blueprint run tx-info --testnet [tx_hash]

# Debug failed transaction
npx blueprint run debug --testnet [tx_hash]

# Verify contract code
npx blueprint run verify --testnet [contract_address]
```

### Logs and monitoring

```bash
# Create monitoring script
# scripts/monitor.ts
import { Address } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider, args: string[]) {
    const contractAddress = args[0];
    
    setInterval(async () => {
        try {
            const balance = await provider.getBalance(Address.parse(contractAddress));
            const timestamp = new Date().toISOString();
            console.log(`[${timestamp}] Contract balance: ${Number(balance)/1e9} TON`);
        } catch (error) {
            console.error('Monitor error:', error);
        }
    }, 30000); // Check every 30 seconds
}
```

## 📚 References

- [TON Documentation](https://docs.ton.org/)
- [Tact Language](https://tact-lang.org/)
- [Blueprint Framework](https://github.com/ton-org/blueprint)
- [TON Center API](https://toncenter.com/api/v2/)
- [TON Explorers](https://tonviewer.com/)

## 🔐 Security

### Best Practices
1. **Never commit private keys**
2. **Use .env for sensitive data**
3. **Test thoroughly on testnet first**
4. **Backup seed phrase securely**
5. **Monitor contract regularly**
6. **Use multi-sig for mainnet**

### Security Checklist
- [ ] Private keys are secured
- [ ] .env file in .gitignore
- [ ] Admin functions have proper access control
- [ ] Fee rates are reasonable
- [ ] Emergency pause mechanism
- [ ] Regular security audits

---

**🎉 Congratulations! You have successfully deployed the TokenTradeMarket smart contract.**

If you encounter any issues, check the logs and use the debug tools provided.