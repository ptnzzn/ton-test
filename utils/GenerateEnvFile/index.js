import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const createEnvFile = () => {
  const projectRoot = path.resolve(__dirname, '../..');
  const envPath = path.join(projectRoot, '.env');
  
  const envTemplate = `# TON API Configuration
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
`;

  try {
    if (fs.existsSync(envPath)) {
      console.log('⚠️  .env file already exists!');
      console.log('📍 Location:', envPath);
      return;
    }
    
    fs.writeFileSync(envPath, envTemplate);
    console.log('✅ .env file created successfully!');
    console.log('📍 Location:', envPath);
    console.log('\n📝 Next steps:');
    console.log('1. Edit .env file with your actual values');
    console.log('2. Get TON API key from: https://t.me/tonapibot');
    console.log('3. Generate wallet using: npm run generate-wallet');
    console.log('4. Get testnet TON from: https://t.me/testgiver_ton_bot');
    
  } catch (error) {
    console.error('❌ Error creating .env file:', error.message);
    process.exit(1);
  }
};

createEnvFile();