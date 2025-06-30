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
    const contractData = await tokenTradeMarket.getGetContractInfo();
    console.log('📊 Contract Info:');
    console.log(`   Admin: ${contractData.adminWallet}`);
    console.log(`   Fee Rate: ${contractData.feeRate}`);
    console.log(`   Is Paused: ${contractData.isPaused}`);
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

### 1. Create testing script
```typescript
// scripts/check.ts
import { Address } from '@ton/core';
import { TokenTradeMarket } from '../build/TokenTradeMarket/tact_TokenTradeMarket';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider, args: string[]) {
    const contractAddress = args.length > 0 ? args[0] : process.env.CONTRACT_ADDRESS;
    
    if (!contractAddress) {
        throw new Error('Contract address required');
    }
    
    const contract = provider.open(TokenTradeMarket.fromAddress(Address.parse(contractAddress)));
    
    try {
        const info = await contract.getGetContractInfo();
        console.log('📊 Contract Status:');
        console.log(`   Address: ${contractAddress}`);
        console.log(`   Admin: ${info.adminWallet}`);
        console.log(`   Fee Rate: ${info.feeRate} (${Number(info.feeRate)/100}%)`);
        console.log(`   Is Paused: ${info.isPaused}`);
        
        // Check balance
        const balance = await provider.getBalance(Address.parse(contractAddress));
        console.log(`   Balance: ${balance} nanoTON (${Number(balance)/1e9} TON)`);
        
    } catch (error) {
        console.error('❌ Error checking contract:', error);
    }
}
```

### 2. Interaction script
```typescript
// scripts/interact.ts
import { toNano, Address } from '@ton/core';
import { TokenTradeMarket } from '../build/TokenTradeMarket/tact_TokenTradeMarket';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider, args: string[]) {
    const contractAddress = args[0];
    const action = args[1];
    
    const contract = provider.open(TokenTradeMarket.fromAddress(Address.parse(contractAddress)));
    
    switch (action) {
        case 'pause':
            await contract.send(
                provider.sender(),
                { value: toNano('0.05') },
                { $$type: 'PauseContract' }
            );
            console.log('✅ Contract paused');
            break;
            
        case 'unpause':
            await contract.send(
                provider.sender(),
                { value: toNano('0.05') },
                { $$type: 'UnpauseContract' }
            );
            console.log('✅ Contract unpaused');
            break;
            
        case 'update-fee':
            const newRate = BigInt(args[2] || '100');
            await contract.send(
                provider.sender(),
                { value: toNano('0.05') },
                {
                    $$type: 'UpdateFeeRate',
                    rate: newRate
                }
            );
            console.log(`✅ Fee rate updated to ${newRate}`);
            break;
            
        case 'add-stable':
            const tokenAddress = Address.parse(args[2]);
            await contract.send(
                provider.sender(),
                { value: toNano('0.05') },
                {
                    $$type: 'UpdateAllowedStable',
                    token: tokenAddress,
                    allowed: true
                }
            );
            console.log(`✅ Added stable token: ${tokenAddress}`);
            break;
            
        default:
            console.log('Available actions: pause, unpause, update-fee, add-stable');
    }
}
```

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