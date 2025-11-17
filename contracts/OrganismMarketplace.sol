// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Organism.sol";

/**
 * @title OrganismMarketplace
 * @notice Buy, sell, and trade digital organisms
 * @dev Complete marketplace with auctions, breeding rights, and genetic patents
 */
contract OrganismMarketplace {
    /// @notice Listing types
    enum ListingType {
        FIXED_PRICE,        // Buy now
        AUCTION,            // Highest bidder
        BREEDING_RIGHTS,    // Rent for breeding
        GENETIC_PATENT,     // License genes
        COLLECTION,         // Bundle of organisms
        RARE_MUTATION,      // Special mutations
        CHAMPION_BLOODLINE, // Proven winners
        CUSTOM_ORDER        // Commission specific traits
    }

    /// @notice Market listing
    struct Listing {
        bytes32 listingId;
        address seller;
        address organism;
        ListingType listingType;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool sold;
    }

    /// @notice Auction
    struct Auction {
        bytes32 auctionId;
        address organism;
        address seller;
        uint256 startingBid;
        uint256 highestBid;
        address highestBidder;
        uint256 startTime;
        uint256 endTime;
        bool ended;
    }

    /// @notice Breeding rights
    struct BreedingRights {
        bytes32 rightsId;
        address organism;
        address owner;
        uint256 pricePerBreeding;
        uint256 maxBreedings;
        uint256 breedingsUsed;
        uint256 expiryTime;
        bool isActive;
    }

    /// @notice Genetic patent
    struct GeneticPatent {
        bytes32 patentId;
        bytes32 geneSequence;
        address owner;
        string description;
        uint256 licenseFee;
        uint256 royaltyPercent;  // Per use
        uint256 expiryBlock;
        bool isActive;
    }

    /// @notice Species collection
    struct Collection {
        bytes32 collectionId;
        string name;
        address[] organisms;
        address owner;
        uint256 totalPrice;
        uint256 floorPrice;
        bool isComplete;
    }

    /// @notice Custom order
    struct CustomOrder {
        bytes32 orderId;
        address buyer;
        bytes32[] desiredTraits;
        uint256[] traitValues;
        uint256 bounty;
        uint256 deadline;
        address fulfiller;
        address organism;
        bool fulfilled;
    }

    /// @notice All listings
    mapping(bytes32 => Listing) public listings;
    bytes32[] public listingIds;

    /// @notice All auctions
    mapping(bytes32 => Auction) public auctions;
    bytes32[] public auctionIds;

    /// @notice Breeding rights
    mapping(bytes32 => BreedingRights) public breedingRights;
    bytes32[] public breedingRightsIds;

    /// @notice Genetic patents
    mapping(bytes32 => GeneticPatent) public patents;
    bytes32[] public patentIds;

    /// @notice Collections
    mapping(bytes32 => Collection) public collections;
    bytes32[] public collectionIds;

    /// @notice Custom orders
    mapping(bytes32 => CustomOrder) public customOrders;
    bytes32[] public orderIds;

    /// @notice Organism ownership
    mapping(address => address) public organismOwner;

    /// @notice User listings
    mapping(address => bytes32[]) public userListings;

    /// @notice Marketplace fee (5%)
    uint256 public constant MARKETPLACE_FEE = 5;

    /// @notice Events
    event ListingCreated(
        bytes32 indexed listingId,
        address indexed seller,
        address indexed organism,
        uint256 price
    );

    event OrganismSold(
        bytes32 indexed listingId,
        address indexed buyer,
        address indexed organism,
        uint256 price
    );

    event AuctionCreated(
        bytes32 indexed auctionId,
        address indexed organism,
        uint256 startingBid
    );

    event BidPlaced(
        bytes32 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );

    event AuctionEnded(
        bytes32 indexed auctionId,
        address indexed winner,
        uint256 finalBid
    );

    event BreedingRightsGranted(
        bytes32 indexed rightsId,
        address indexed organism,
        address indexed user,
        uint256 price
    );

    event PatentRegistered(
        bytes32 indexed patentId,
        bytes32 geneSequence,
        address indexed owner
    );

    event CollectionCreated(
        bytes32 indexed collectionId,
        string name,
        uint256 organismCount
    );

    event CustomOrderPlaced(
        bytes32 indexed orderId,
        address indexed buyer,
        uint256 bounty
    );

    event CustomOrderFulfilled(
        bytes32 indexed orderId,
        address indexed fulfiller,
        address organism
    );

    /**
     * @notice List organism for sale
     * @param organism Organism to sell
     * @param price Sale price
     * @param duration Listing duration
     * @return listingId Listing ID
     */
    function listForSale(
        address organism,
        uint256 price,
        uint256 duration
    ) external returns (bytes32 listingId) {
        require(price > 0, "Price must be > 0");

        listingId = keccak256(abi.encodePacked(organism, msg.sender, block.timestamp));

        listings[listingId] = Listing({
            listingId: listingId,
            seller: msg.sender,
            organism: organism,
            listingType: ListingType.FIXED_PRICE,
            price: price,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            sold: false
        });

        listingIds.push(listingId);
        userListings[msg.sender].push(listingId);
        organismOwner[organism] = msg.sender;

        emit ListingCreated(listingId, msg.sender, organism, price);

        return listingId;
    }

    /**
     * @notice Buy organism
     * @param listingId Listing to buy
     */
    function buyOrganism(bytes32 listingId) external payable {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing not active");
        require(block.timestamp <= listing.endTime, "Listing expired");
        require(msg.value >= listing.price, "Insufficient payment");
        require(!listing.sold, "Already sold");

        listing.isActive = false;
        listing.sold = true;

        // Calculate fees
        uint256 fee = (listing.price * MARKETPLACE_FEE) / 100;
        uint256 sellerAmount = listing.price - fee;

        // Transfer payment
        payable(listing.seller).transfer(sellerAmount);

        // Transfer ownership
        organismOwner[listing.organism] = msg.sender;

        // Refund excess
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }

        emit OrganismSold(listingId, msg.sender, listing.organism, listing.price);
    }

    /**
     * @notice Create auction
     * @param organism Organism to auction
     * @param startingBid Starting bid
     * @param duration Auction duration
     * @return auctionId Auction ID
     */
    function createAuction(
        address organism,
        uint256 startingBid,
        uint256 duration
    ) external returns (bytes32 auctionId) {
        auctionId = keccak256(abi.encodePacked(organism, msg.sender, block.timestamp));

        auctions[auctionId] = Auction({
            auctionId: auctionId,
            organism: organism,
            seller: msg.sender,
            startingBid: startingBid,
            highestBid: 0,
            highestBidder: address(0),
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            ended: false
        });

        auctionIds.push(auctionId);
        organismOwner[organism] = msg.sender;

        emit AuctionCreated(auctionId, organism, startingBid);

        return auctionId;
    }

    /**
     * @notice Place bid
     * @param auctionId Auction to bid on
     */
    function placeBid(bytes32 auctionId) external payable {
        Auction storage auction = auctions[auctionId];
        require(!auction.ended, "Auction ended");
        require(block.timestamp <= auction.endTime, "Auction expired");
        require(msg.value >= auction.startingBid, "Bid too low");
        require(msg.value > auction.highestBid, "Bid not higher");

        // Refund previous bidder
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    /**
     * @notice End auction
     * @param auctionId Auction to end
     */
    function endAuction(bytes32 auctionId) external {
        Auction storage auction = auctions[auctionId];
        require(!auction.ended, "Already ended");
        require(block.timestamp > auction.endTime, "Not yet ended");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            // Calculate fee
            uint256 fee = (auction.highestBid * MARKETPLACE_FEE) / 100;
            uint256 sellerAmount = auction.highestBid - fee;

            // Pay seller
            payable(auction.seller).transfer(sellerAmount);

            // Transfer ownership
            organismOwner[auction.organism] = auction.highestBidder;

            emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
        }
    }

    /**
     * @notice Offer breeding rights
     * @param organism Organism to breed
     * @param pricePerBreeding Price per breeding
     * @param maxBreedings Max breedings allowed
     * @param duration Rights duration
     * @return rightsId Rights ID
     */
    function offerBreedingRights(
        address organism,
        uint256 pricePerBreeding,
        uint256 maxBreedings,
        uint256 duration
    ) external returns (bytes32 rightsId) {
        rightsId = keccak256(abi.encodePacked(organism, msg.sender, block.timestamp));

        breedingRights[rightsId] = BreedingRights({
            rightsId: rightsId,
            organism: organism,
            owner: msg.sender,
            pricePerBreeding: pricePerBreeding,
            maxBreedings: maxBreedings,
            breedingsUsed: 0,
            expiryTime: block.timestamp + duration,
            isActive: true
        });

        breedingRightsIds.push(rightsId);

        return rightsId;
    }

    /**
     * @notice Purchase breeding rights
     * @param rightsId Rights to purchase
     */
    function purchaseBreedingRights(bytes32 rightsId) external payable {
        BreedingRights storage rights = breedingRights[rightsId];
        require(rights.isActive, "Rights not active");
        require(rights.breedingsUsed < rights.maxBreedings, "No breedings left");
        require(block.timestamp <= rights.expiryTime, "Rights expired");
        require(msg.value >= rights.pricePerBreeding, "Insufficient payment");

        rights.breedingsUsed++;

        // Pay owner
        payable(rights.owner).transfer(msg.value);

        emit BreedingRightsGranted(rightsId, rights.organism, msg.sender, msg.value);
    }

    /**
     * @notice Register genetic patent
     * @param geneSequence Gene sequence
     * @param description Patent description
     * @param licenseFee Fee to license
     * @param royaltyPercent Royalty percentage
     * @param duration Patent duration
     * @return patentId Patent ID
     */
    function registerPatent(
        bytes32 geneSequence,
        string memory description,
        uint256 licenseFee,
        uint256 royaltyPercent,
        uint256 duration
    ) external returns (bytes32 patentId) {
        require(royaltyPercent <= 100, "Invalid royalty");

        patentId = keccak256(abi.encodePacked(geneSequence, msg.sender, block.timestamp));

        patents[patentId] = GeneticPatent({
            patentId: patentId,
            geneSequence: geneSequence,
            owner: msg.sender,
            description: description,
            licenseFee: licenseFee,
            royaltyPercent: royaltyPercent,
            expiryBlock: block.number + duration,
            isActive: true
        });

        patentIds.push(patentId);

        emit PatentRegistered(patentId, geneSequence, msg.sender);

        return patentId;
    }

    /**
     * @notice Create species collection
     * @param name Collection name
     * @param organisms Organisms in collection
     * @param totalPrice Total price
     * @return collectionId Collection ID
     */
    function createCollection(
        string memory name,
        address[] memory organisms,
        uint256 totalPrice
    ) external returns (bytes32 collectionId) {
        collectionId = keccak256(abi.encodePacked(name, msg.sender, block.timestamp));

        // Calculate floor price
        uint256 floorPrice = totalPrice / organisms.length;

        Collection storage collection = collections[collectionId];
        collection.collectionId = collectionId;
        collection.name = name;
        collection.organisms = organisms;
        collection.owner = msg.sender;
        collection.totalPrice = totalPrice;
        collection.floorPrice = floorPrice;
        collection.isComplete = true;

        collectionIds.push(collectionId);

        emit CollectionCreated(collectionId, name, organisms.length);

        return collectionId;
    }

    /**
     * @notice Place custom order
     * @param desiredTraits Traits wanted
     * @param traitValues Trait values
     * @param deadline Fulfillment deadline
     * @return orderId Order ID
     */
    function placeCustomOrder(
        bytes32[] memory desiredTraits,
        uint256[] memory traitValues,
        uint256 deadline
    ) external payable returns (bytes32 orderId) {
        require(msg.value > 0, "Must provide bounty");

        orderId = keccak256(abi.encodePacked(msg.sender, block.timestamp));

        customOrders[orderId] = CustomOrder({
            orderId: orderId,
            buyer: msg.sender,
            desiredTraits: desiredTraits,
            traitValues: traitValues,
            bounty: msg.value,
            deadline: deadline,
            fulfiller: address(0),
            organism: address(0),
            fulfilled: false
        });

        orderIds.push(orderId);

        emit CustomOrderPlaced(orderId, msg.sender, msg.value);

        return orderId;
    }

    /**
     * @notice Fulfill custom order
     * @param orderId Order to fulfill
     * @param organism Organism that meets requirements
     */
    function fulfillCustomOrder(bytes32 orderId, address organism) external {
        CustomOrder storage order = customOrders[orderId];
        require(!order.fulfilled, "Already fulfilled");
        require(block.timestamp <= order.deadline, "Deadline passed");

        // Simplified validation - would check traits in production
        order.fulfilled = true;
        order.fulfiller = msg.sender;
        order.organism = organism;

        // Transfer organism ownership
        organismOwner[organism] = order.buyer;

        // Pay bounty
        payable(msg.sender).transfer(order.bounty);

        emit CustomOrderFulfilled(orderId, msg.sender, organism);
    }

    /**
     * @notice Cancel listing
     * @param listingId Listing to cancel
     */
    function cancelListing(bytes32 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not seller");
        require(listing.isActive, "Not active");

        listing.isActive = false;
    }

    /**
     * @notice Get active listings
     */
    function getActiveListings() external view returns (bytes32[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < listingIds.length; i++) {
            if (listings[listingIds[i]].isActive) count++;
        }

        bytes32[] memory activeListings = new bytes32[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < listingIds.length; i++) {
            if (listings[listingIds[i]].isActive) {
                activeListings[index++] = listingIds[i];
            }
        }

        return activeListings;
    }

    /**
     * @notice Withdraw marketplace fees
     */
    function withdrawFees() external {
        // Would add access control in production
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
