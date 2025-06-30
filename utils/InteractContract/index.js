import { Address, toNano } from '@ton/core';
import { TokenTradeMarket } from '../../build/TokenTradeMarket_TokenTradeMarket.js';
import { TonClient, WalletContractV4 } from '@ton/ton';
import { getHttpEndpoint } from '@orbs-network/ton-access';
import { mnemonicToWalletKey } from '@ton/crypto';
import * as dotenv from 'dotenv';
import readline from 'readline';

// Load environment variables
dotenv.config();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (prompt) => {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
};

const interactContract = async () => {
  try {
    console.log('🔧 Starting Contract Interaction Tool...');
    
    // Get testnet endpoint
    const endpoint = await getHttpEndpoint({ network: 'testnet' });
    const client = new TonClient({ endpoint });
    
    // Contract address from environment
    const contractAddress = process.env.CONTRACT_ADDRESS;
    if (!contractAddress) {
      throw new Error('❌ CONTRACT_ADDRESS not found in .env file');
    }
    
    console.log(`📍 Interacting with contract at: ${contractAddress}`);
    
    // Initialize contract
    const contract = client.open(
      TokenTradeMarket.fromAddress(Address.parse(contractAddress))
    );
    
    // Show menu
    console.log('\n📋 Available Actions:');
    console.log('1. Pause Contract (Admin only)');
    console.log('2. Unpause Contract (Admin only)');
    console.log('3. Update Fee Rate (Admin only)');
    console.log('4. Add Allowed Stable Token (Admin only)');
    console.log('5. Remove Allowed Stable Token (Admin only)');
    console.log('6. Create Sell Order');
    console.log('7. Cancel Sell Order');
    console.log('8. Buy Order');
    console.log('9. Check Contract Status');
    console.log('0. Exit');
    
    const choice = await question('\nSelect an action (0-9): ');
    
    switch (choice) {
      case '1':
        await pauseContract(contract);
        break;
      case '2':
        await unpauseContract(contract);
        break;
      case '3':
        await updateFeeRate(contract);
        break;
      case '4':
        await addStableToken(contract);
        break;
      case '5':
        await removeStableToken(contract);
        break;
      case '6':
        await createSellOrder(contract);
        break;
      case '7':
        await cancelSellOrder(contract);
        break;
      case '8':
        await buyOrder(contract);
        break;
      case '9':
        await checkContractStatus(contract);
        break;
      case '0':
        console.log('👋 Goodbye!');
        break;
      default:
        console.log('❌ Invalid choice');
    }
    
  } catch (error) {
    console.error('❌ Interaction failed:', error.message);
  } finally {
    rl.close();
  }
};

const pauseContract = async (contract) => {
  console.log('\n⏸️ Pausing contract...');
  console.log('⚠️ Note: This requires admin privileges and a wallet with TON');
  console.log('💡 This is a simulation - actual transaction requires wallet setup');
  
  const messageBody = {
    $$type: 'PauseContract'
  };
  
  console.log('📤 Message to send:', JSON.stringify(messageBody, null, 2));
  console.log('💰 Required value: 0.05 TON');
  console.log('✅ Pause message prepared (wallet integration needed for actual sending)');
};

const unpauseContract = async (contract) => {
  console.log('\n▶️ Unpausing contract...');
  console.log('⚠️ Note: This requires admin privileges and a wallet with TON');
  console.log('💡 This is a simulation - actual transaction requires wallet setup');
  
  const messageBody = {
    $$type: 'UnpauseContract'
  };
  
  console.log('📤 Message to send:', JSON.stringify(messageBody, null, 2));
  console.log('💰 Required value: 0.05 TON');
  console.log('✅ Unpause message prepared (wallet integration needed for actual sending)');
};

const updateFeeRate = async (contract) => {
  console.log('\n💸 Updating fee rate...');
  const newRate = await question('Enter new fee rate (basis points, e.g., 100 for 1%): ');
  
  const messageBody = {
    $$type: 'UpdateFeeRate',
    rate: BigInt(newRate)
  };
  
  console.log('📤 Message to send:', JSON.stringify(messageBody, (key, value) => 
    typeof value === 'bigint' ? value.toString() : value, 2));
  console.log('💰 Required value: 0.05 TON');
  console.log('✅ Fee rate update message prepared');
};

const addStableToken = async (contract) => {
  console.log('\n🪙 Adding allowed stable token...');
  const tokenAddress = await question('Enter stable token address: ');
  
  try {
    const messageBody = {
      $$type: 'UpdateAllowedStable',
      token: Address.parse(tokenAddress),
      allowed: true
    };
    
    console.log('📤 Message to send:', JSON.stringify(messageBody, null, 2));
    console.log('💰 Required value: 0.05 TON');
    console.log('✅ Add stable token message prepared');
  } catch (error) {
    console.error('❌ Invalid address format');
  }
};

const removeStableToken = async (contract) => {
  console.log('\n🚫 Removing allowed stable token...');
  const tokenAddress = await question('Enter stable token address to remove: ');
  
  try {
    const messageBody = {
      $$type: 'UpdateAllowedStable',
      token: Address.parse(tokenAddress),
      allowed: false
    };
    
    console.log('📤 Message to send:', JSON.stringify(messageBody, null, 2));
    console.log('💰 Required value: 0.05 TON');
    console.log('✅ Remove stable token message prepared');
  } catch (error) {
    console.error('❌ Invalid address format');
  }
};

const createSellOrder = async (contract) => {
  console.log('\n📝 Creating sell order...');
  const orderId = await question('Enter order ID: ');
  const price = await question('Enter price (in nanoTON): ');
  const minBuyPrice = await question('Enter minimum buy price (in nanoTON): ');
  const tokenAddress = await question('Enter token address: ');
  const amount = await question('Enter token amount: ');
  
  try {
    const messageBody = {
      $$type: 'CreateOrder',
      id: BigInt(orderId),
      price: BigInt(price),
      minBuyPrice: BigInt(minBuyPrice),
      token: Address.parse(tokenAddress),
      amount: BigInt(amount)
    };
    
    console.log('📤 Message to send:', JSON.stringify(messageBody, (key, value) => 
      typeof value === 'bigint' ? value.toString() : value, 2));
    console.log('💰 Required value: 0.1 TON');
    console.log('✅ Create order message prepared');
  } catch (error) {
    console.error('❌ Invalid input format');
  }
};

const cancelSellOrder = async (contract) => {
  console.log('\n❌ Canceling sell order...');
  const orderId = await question('Enter order ID to cancel: ');
  
  const messageBody = {
    $$type: 'CancelOrder',
    id: BigInt(orderId)
  };
  
  console.log('📤 Message to send:', JSON.stringify(messageBody, (key, value) => 
    typeof value === 'bigint' ? value.toString() : value, 2));
  console.log('💰 Required value: 0.05 TON');
  console.log('✅ Cancel order message prepared');
};

const buyOrder = async (contract) => {
  console.log('\n🛒 Buying from order...');
  const orderId = await question('Enter order ID to buy from: ');
  const amount = await question('Enter amount to buy: ');
  const stableTokenAddress = await question('Enter stable token address for payment: ');
  
  try {
    const messageBody = {
      $$type: 'BuyOrder',
      id: BigInt(orderId),
      amount: BigInt(amount),
      stableToken: Address.parse(stableTokenAddress)
    };
    
    console.log('📤 Message to send:', JSON.stringify(messageBody, (key, value) => 
      typeof value === 'bigint' ? value.toString() : value, 2));
    console.log('💰 Required value: 0.1 TON');
    console.log('✅ Buy order message prepared');
  } catch (error) {
    console.error('❌ Invalid input format');
  }
};

const checkContractStatus = async (contract) => {
  console.log('\n📊 Checking contract status...');
  
  try {
    const adminWallet = await contract.getGetAdminWallet();
    const feeRate = await contract.getGetFeeRate();
    const isPaused = await contract.getGetIsPaused();
    console.log('✅ Contract Status:');
    console.log(`   Admin Wallet: ${adminWallet}`);
    console.log(`   Fee Rate: ${feeRate} basis points (${Number(feeRate)/100}%)`);
    console.log(`   Is Paused: ${isPaused}`);
    
    // Note: getGetNextOrderId() function may not exist in the updated contract
    // You may need to check if this function is still available
    try {
      const nextOrderId = await contract.getGetNextOrderId();
      console.log(`   Next Order ID: ${nextOrderId}`);
    } catch (orderIdError) {
      console.log('   Next Order ID: Not available (function may have been removed)');
    }
    
  } catch (error) {
    console.error('❌ Failed to get contract status:', error.message);
  }
};

console.log('🚀 Contract Interaction Tool');
console.log('💡 Note: This tool prepares messages but requires wallet integration for actual sending');
console.log('📖 For actual transactions, use Blueprint with proper wallet setup');

interactContract();