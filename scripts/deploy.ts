import { Address, toNano } from '@ton/core';
import { TokenTradeMarket } from '../build/TokenTradeMarket_TokenTradeMarket';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    // Admin wallet address (replace with your address)
    const adminWallet = Address.parse('YOUR_ADMIN_WALLET_ADDRESS');
    
    // Backend signer address (replace with your address)
    const backendSigner = Address.parse('YOUR_BACKEND_SIGNER_ADDRESS');
    
    // Stable token address (replace with actual stable token address)
    const stableToken = Address.parse('YOUR_STABLE_TOKEN_ADDRESS');
    
    // Fee receiver address (replace with your address)
    const feeReceiver = Address.parse('YOUR_FEE_RECEIVER_ADDRESS');

    const tokenTradeMarket = provider.open(await TokenTradeMarket.fromInit(
        adminWallet,
        backendSigner,
        stableToken,
        feeReceiver
    ));

    await tokenTradeMarket.send(
        provider.sender(),
        {
            value: toNano('0.1'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n
        }
    );

    await provider.waitForDeploy(tokenTradeMarket.address);

    console.log('✅ Contract deployed at:', tokenTradeMarket.address);
    console.log('🔗 Explorer:', `https://tonviewer.com/${tokenTradeMarket.address}`);
}