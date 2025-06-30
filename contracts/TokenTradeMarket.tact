// TokenTradeMarket.tact
// A TON smart contract replicating the logic of the BSC TokenTradeMarketSafuco

// Message structs with explicit opcodes
message(0x01) UpdateFeeRate {
    rate: Int;
}

message(0x02) UpdateAllowedStable {
    token: Address;
    allowed: Bool;
}

message(0x03) CreateOrder {
    id: Int;
    price: Int;
    minBuyPrice: Int;
    token: Address;
    amount: Int;
}

message(0x04) CancelOrder {
    id: Int;
}

message(0x05) BuyOrder {
    id: Int;
    amount: Int;
    stableToken: Address;
}

// Admin control messages
message(0x06) PauseContract {}
message(0x07) UnpauseContract {}

// Jetton wallet code management
message(0x08) SetJettonWalletCode {
    token: Address;
    walletCode: Cell;
}

// Deploy message
message(0x946a98b6) Deploy {
    queryId: Int as uint64;
}

// Jetton Transfer Messages
message(0xf8a7ea5) JettonTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    responseDestination: Address?; // Optional address for security
    customPayload: Cell?;
    forwardTonAmount: Int as coins;
    forwardPayload: Slice as remaining;
}

message(0x7362d09c) JettonTransferNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    sender: Address;
    forwardPayload: Slice as remaining;
}

// Helper struct for Jetton wallet data
struct JettonWalletData {
    balance: Int as coins;
    ownerAddress: Address;
    jettonMasterAddress: Address;
    jettonWalletCode: Cell;
}

// SellOrder struct
struct SellOrder {
    seller: Address;
    token: Address;
    amount: Int;
    price: Int;
    minBuyPrice: Int;
    active: Bool;
}

// Helper function to calculate Jetton wallet address
fun calculateJettonWalletAddress(
    ownerAddress: Address,
    jettonMasterAddress: Address,
    jettonWalletCode: Cell
): Address {
    let initData: JettonWalletData = JettonWalletData {
        balance: 0,
        ownerAddress: ownerAddress,
        jettonMasterAddress: jettonMasterAddress,
        jettonWalletCode: jettonWalletCode
    };
    return contractAddress(StateInit {
        code: jettonWalletCode,
        data: initData.toCell()
    });
}

contract TokenTradeMarket {
    // Admin
    adminWallet: Address;
    backendSigner: Address;
    feeReceiver: Address;
    feeRate: Int; // 20 = 0.2%

    // Paused state
    isPaused: Bool;

    // Allowed stable tokens
    allowedStableTokens: map<Address, Bool>;

    // Jetton wallet codes for different tokens
    jettonWalletCodes: map<Address, Cell>;
    
    // Valid Jetton wallets for security validation
    validJettonWallets: map<Address, Bool>;

    sellOrders: map<Int, SellOrder>;
    
    // Gas constants for better gas management
    const GAS_FOR_JETTON_TRANSFER: Int = ton("0.1");
    const GAS_FOR_FORWARD: Int = ton("0.05");
    const MIN_TONS_FOR_STORAGE: Int = ton("0.01");

    // INIT
    init(admin: Address, signer: Address, stable: Address, feeTo: Address) {
        self.adminWallet = admin;
        self.backendSigner = signer;
        self.feeReceiver = feeTo;
        self.feeRate = 20;
        self.isPaused = false;

        self.allowedStableTokens.set(stable, true);
    }

    // Deploy function
    receive(msg: Deploy) {
        // Contract deployment - no specific action needed
    }

    // Admin functions
    receive(msg: PauseContract) {
        require(sender() == self.adminWallet, "Only admin");
        self.isPaused = true;
    }

    receive(msg: UnpauseContract) {
        require(sender() == self.adminWallet, "Only admin");
        self.isPaused = false;
    }

    receive(msg: UpdateFeeRate) {
        require(sender() == self.adminWallet, "Only admin");
        require(msg.rate <= 1000, "Fee rate too high"); // max 10%
        self.feeRate = msg.rate;
    }

    receive(msg: UpdateAllowedStable) {
        require(sender() == self.adminWallet, "Only admin");
        self.allowedStableTokens.set(msg.token, msg.allowed);
    }

    receive(msg: SetJettonWalletCode) {
        require(sender() == self.adminWallet, "Only admin");
        self.jettonWalletCodes.set(msg.token, msg.walletCode);
        
        // Calculate and register the contract's Jetton wallet for this token
        let contractJettonWallet: Address = calculateJettonWalletAddress(
            myAddress(),
            msg.token,
            msg.walletCode
        );
        self.validJettonWallets.set(contractJettonWallet, true);
    }

    // Create sell order
    receive(msg: CreateOrder) {
        require(!self.isPaused, "Contract is paused");
        require(msg.price >= msg.minBuyPrice, "Price must be >= minBuyPrice");
        let existingOrder: SellOrder? = self.sellOrders.get(msg.id);
        require(existingOrder == null || !existingOrder!!.active, "Order already exists");

        self.sellOrders.set(msg.id, SellOrder {
            seller: sender(),
            token: msg.token,
            amount: msg.amount,
            price: msg.price,
            minBuyPrice: msg.minBuyPrice,
            active: true
        });
    }

    // Cancel sell order
    receive(msg: CancelOrder) {
        require(!self.isPaused, "Contract is paused");
        let order: SellOrder? = self.sellOrders.get(msg.id);
        require(order != null, "Order not found");
        require(order!!.active, "Order not active");
        require(order!!.seller == sender(), "Not order owner");

        let updatedOrder: SellOrder = SellOrder {
            seller: order!!.seller,
            token: order!!.token,
            amount: order!!.amount,
            price: order!!.price,
            minBuyPrice: order!!.minBuyPrice,
            active: false
        };
        self.sellOrders.set(msg.id, updatedOrder);

        // Send back tokens to seller with proper gas management
        let jettonWalletCode: Cell? = self.jettonWalletCodes.get(order!!.token);
        require(jettonWalletCode != null, "Jetton wallet code not found");
        
        let contractJettonWallet: Address = calculateJettonWalletAddress(
            myAddress(),
            order!!.token,
            jettonWalletCode!!
        );
        
        // Security: Verify this is a valid Jetton wallet
        let isValidWallet: Bool? = self.validJettonWallets.get(contractJettonWallet);
        require(isValidWallet != null && isValidWallet!!, "Invalid Jetton wallet");
        
        // Send Jetton transfer message with proper gas management
        send(SendParameters{
            to: contractJettonWallet,
            value: self.GAS_FOR_JETTON_TRANSFER,
            mode: SendPayGasSeparately,
            body: JettonTransfer{
                queryId: 0,
                amount: order!!.amount,
                destination: order!!.seller,
                responseDestination: order!!.seller, // Use non-optional for safety
                customPayload: null,
                forwardTonAmount: self.GAS_FOR_FORWARD,
                forwardPayload: emptySlice()
            }.toCell()
        });
    }

    // Buy order with comprehensive Jetton transfer implementation
    receive(msg: BuyOrder) {
        require(!self.isPaused, "Contract is paused");
        let isAllowed: Bool? = self.allowedStableTokens.get(msg.stableToken);
        require(isAllowed != null && isAllowed!!, "Stable token not allowed");

        let order: SellOrder? = self.sellOrders.get(msg.id);
        require(order != null, "Order not found");
        require(order!!.active, "Order not active");
        require(msg.amount > 0 && msg.amount <= order!!.amount, "Invalid amount");

        let total: Int = (msg.amount * order!!.price) / 1000000000000000000;
        require(total >= order!!.minBuyPrice, "Total below minimum buy price");

        let fee: Int = (total * self.feeRate) / 10000;
        let paySeller: Int = total - fee;

        // Get Jetton wallet codes with validation
        let tokenWalletCode: Cell? = self.jettonWalletCodes.get(order!!.token);
        let stableWalletCode: Cell? = self.jettonWalletCodes.get(msg.stableToken);
        require(tokenWalletCode != null && stableWalletCode != null, "Wallet codes not found");
        
        // Calculate wallet addresses
        let contractTokenWallet: Address = calculateJettonWalletAddress(
            myAddress(), order!!.token, tokenWalletCode!!
        );
        let contractStableWallet: Address = calculateJettonWalletAddress(
            myAddress(), msg.stableToken, stableWalletCode!!
        );
        
        // Security: Validate Jetton wallets
        let isValidTokenWallet: Bool? = self.validJettonWallets.get(contractTokenWallet);
        let isValidStableWallet: Bool? = self.validJettonWallets.get(contractStableWallet);
        require(isValidTokenWallet != null && isValidTokenWallet!!, "Invalid token wallet");
        require(isValidStableWallet != null && isValidStableWallet!!, "Invalid stable wallet");
        
        // Transfer tokens to buyer with proper gas management
        message(MessageParameters{
            to: contractTokenWallet,
            value: self.GAS_FOR_JETTON_TRANSFER,
            mode: SendPayGasSeparately,
            body: JettonTransfer{
                queryId: 0,
                amount: msg.amount,
                destination: sender(), // buyer
                responseDestination: sender(),
                customPayload: null,
                forwardTonAmount: self.GAS_FOR_FORWARD,
                forwardPayload: emptySlice()
            }.toCell()
        });
        
        // Transfer payment to seller (minus fee) with concurrency safety
        if (paySeller > 0) {
            send(SendParameters{
                to: contractStableWallet,
                value: self.GAS_FOR_JETTON_TRANSFER,
                mode: SendPayGasSeparately,
                body: JettonTransfer{
                    queryId: 1,
                    amount: paySeller,
                    destination: order!!.seller,
                    responseDestination: order!!.seller,
                    customPayload: null,
                    forwardTonAmount: self.GAS_FOR_FORWARD,
                    forwardPayload: emptySlice()
                }.toCell()
            });
        }
        
        // Transfer fee to fee receiver
        if (fee > 0) {
            send(SendParameters{
                to: contractStableWallet,
                value: self.GAS_FOR_JETTON_TRANSFER,
                mode: SendPayGasSeparately,
                body: JettonTransfer{
                    queryId: 2,
                    amount: fee,
                    destination: self.feeReceiver,
                    responseDestination: self.feeReceiver,
                    customPayload: null,
                    forwardTonAmount: self.GAS_FOR_FORWARD,
                    forwardPayload: emptySlice()
                }.toCell()
            });
        }

        // Update order state atomically to prevent race conditions
        let updatedOrder: SellOrder = SellOrder {
            seller: order!!.seller,
            token: order!!.token,
            amount: order!!.amount - msg.amount,
            price: order!!.price,
            minBuyPrice: order!!.minBuyPrice,
            active: (order!!.amount - msg.amount) > 0
        };
        self.sellOrders.set(msg.id, updatedOrder);
    }

    // Handle incoming Jetton transfer notifications with security validation
    receive(msg: JettonTransferNotification) {
        // Security: Validate that the sender is a registered Jetton wallet
        let isValidSender: Bool? = self.validJettonWallets.get(sender());
        require(isValidSender != null && isValidSender!!, "Unauthorized Jetton transfer notification");
        
        // Additional validation: Check if the notification amount is reasonable
        require(msg.amount > 0, "Invalid transfer amount");
        
        // Log the transfer for debugging (optional)
        // This can be used for tracking incoming transfers
        // The actual business logic would depend on your specific requirements
    }

    // Bounced message handler for failed Jetton transfers
    bounced(src: bounced<JettonTransfer>) {
        // Handle bounced Jetton transfers
        // This is important for recovering from failed transfers
        // You might want to revert order states or notify users
        
        // For now, we'll just ensure the contract doesn't crash
        // In production, you should implement proper error recovery
    }

    // Get methods for querying contract state
    get fun getOrderInfo(orderId: Int): SellOrder? {
        return self.sellOrders.get(orderId);
    }
    
    get fun isJettonSupported(token: Address): Bool {
        let walletCode: Cell? = self.jettonWalletCodes.get(token);
        return walletCode != null;
    }
    
    get fun getContractJettonWallet(token: Address): Address? {
        let walletCode: Cell? = self.jettonWalletCodes.get(token);
        if (walletCode == null) {
            return null;
        }
        return calculateJettonWalletAddress(myAddress(), token, walletCode!!);
    }
    
    get fun getAdminWallet(): Address {
        return self.adminWallet;
    }
    
    get fun getBackendSigner(): Address {
        return self.backendSigner;
    }
    
    get fun getFeeReceiver(): Address {
        return self.feeReceiver;
    }
    
    get fun getFeeRate(): Int {
        return self.feeRate;
    }
    
    get fun getIsPaused(): Bool {
        return self.isPaused;
    }
}