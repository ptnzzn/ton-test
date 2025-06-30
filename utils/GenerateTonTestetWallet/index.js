import { mnemonicNew, mnemonicToWalletKey } from '@ton/crypto';
import { WalletContractV4 } from '@ton/ton';
import { TonClient } from '@ton/ton';
import { getHttpEndpoint } from '@orbs-network/ton-access';

const run = async () => {
  // 1. Generate mnemonic (24 words)
  const mnemonic = await mnemonicNew();
  console.log("✅ Mnemonic:", mnemonic.join(' '));

  // 2. Convert to key pair
  const key = await mnemonicToWalletKey(mnemonic);

  // 3. Create wallet contract (v4)
  const wallet = WalletContractV4.create({
    workchain: 0,
    publicKey: key.publicKey,
  });

  // 4. Get testnet endpoint
  const endpoint = await getHttpEndpoint({ network: 'testnet' });

  const client = new TonClient({ endpoint });

  // 5. Get wallet address & balance
  const address = wallet.address.toString();
  console.log("📬 Address:", address);

  const balance = await client.getBalance(wallet.address);
  console.log("💰 Balance:", balance / 1e9, "TON");
};

run();