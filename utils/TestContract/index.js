import { Address, toNano } from '@ton/core';
import { TokenTradeMarket } from '../../build/TokenTradeMarket_TokenTradeMarket.js';
import { TonClient } from '@ton/ton';
import { getHttpEndpoint } from '@orbs-network/ton-access';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const testContract = async () => {
  try {
    console.log('🧪 Starting Contract Testing...');
    
    // Get testnet endpoint
    const endpoint = await getHttpEndpoint({ network: 'testnet' });
    const client = new TonClient({ endpoint });
    
    // Contract address from environment or prompt
    const contractAddress = process.env.CONTRACT_ADDRESS;
    if (!contractAddress) {
      throw new Error('❌ CONTRACT_ADDRESS not found in .env file');
    }
    
    console.log(`📍 Testing contract at: ${contractAddress}`);
    
    // Initialize contract
    const contract = client.open(
      TokenTradeMarket.fromAddress(Address.parse(contractAddress))
    );
    
    // Test 1: Get contract info
    console.log('\n📊 Test 1: Getting contract information...');
    try {
      const adminWallet = await contract.getGetAdminWallet();
      const feeRate = await contract.getGetFeeRate();
      const isPaused = await contract.getGetIsPaused();
      console.log('✅ Contract Info Retrieved:');
      console.log(`   Admin Wallet: ${adminWallet}`);
      console.log(`   Fee Rate: ${feeRate} basis points (${Number(feeRate)/100}%)`);
      console.log(`   Is Paused: ${isPaused}`);
    } catch (error) {
      console.error('❌ Failed to get contract info:', error.message);
    }
    
    // Test 2: Check contract balance
    console.log('\n💰 Test 2: Checking contract balance...');
    try {
      const balance = await client.getBalance(Address.parse(contractAddress));
      console.log(`✅ Contract Balance: ${balance} nanoTON (${Number(balance)/1e9} TON)`);
    } catch (error) {
      console.error('❌ Failed to get balance:', error.message);
    }
    
    // Test 3: Check if stable token is allowed (using a dummy address)
    console.log('\n🪙 Test 3: Checking stable token allowance...');
    try {
      const dummyStableAddress = Address.parse('EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c');
      const isAllowed = await contract.getGetIsAllowedStable(dummyStableAddress);
      console.log(`✅ Dummy stable token allowed: ${isAllowed}`);
    } catch (error) {
      console.error('❌ Failed to check stable token:', error.message);
    }
    
    // Test 4: Get next order ID
    console.log('\n🔢 Test 4: Getting next order ID...');
    try {
      const nextOrderId = await contract.getGetNextOrderId();
      console.log(`✅ Next Order ID: ${nextOrderId}`);
    } catch (error) {
      console.error('❌ Failed to get next order ID:', error.message);
    }
    
    // Test 5: Try to get a sell order (should return null for non-existent order)
    console.log('\n📋 Test 5: Checking sell order (ID: 1)...');
    try {
      const sellOrder = await contract.getGetSellOrder(1n);
      if (sellOrder) {
        console.log('✅ Sell Order Found:');
        console.log(`   Seller: ${sellOrder.seller}`);
        console.log(`   Token: ${sellOrder.token}`);
        console.log(`   Amount: ${sellOrder.amount}`);
        console.log(`   Price: ${sellOrder.price}`);
        console.log(`   Min Buy Price: ${sellOrder.minBuyPrice}`);
        console.log(`   Active: ${sellOrder.active}`);
      } else {
        console.log('✅ No sell order found with ID 1 (expected for new contract)');
      }
    } catch (error) {
      console.error('❌ Failed to get sell order:', error.message);
    }
    
    console.log('\n🎉 Contract testing completed!');
    console.log('\n📝 Test Summary:');
    console.log('   - Contract info retrieval: Tested');
    console.log('   - Balance checking: Tested');
    console.log('   - Stable token allowance: Tested');
    console.log('   - Next order ID: Tested');
    console.log('   - Sell order retrieval: Tested');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
};

testContract();