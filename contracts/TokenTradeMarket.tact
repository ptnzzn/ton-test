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

// Deploy message
message(0x946a98b6) Deploy {
    queryId: Int as uint64;
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

    sellOrders: map<Int, SellOrder>;

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

        // TODO: Send back token to seller (implement Jetton transfer)
        // This requires proper Jetton contract interaction
    }

    // Buy order
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

        // TODO: Implement proper Jetton transfers
        // These require proper Jetton contract interaction
        
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
}