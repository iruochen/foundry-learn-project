// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    struct Listing {
        address seller;
        address ntfContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    IERC20 public paymentToken;

    mapping(uint256 => Listing) public listings;
    uint256 public listingCounter;

    event NFTListed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );

    event NFTPurchased(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );

    event ListingCancelled(uint256 indexed listingId);

    constructor(address _paymentToken) {
        require(_paymentToken != address(0), "Invalid payment token address");
        paymentToken = IERC20(_paymentToken);
    }

    function list(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(nftContract != address(0), "Invalid NFT contract");

        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");
        require(
            nft.isApprovedForAll(msg.sender, address(this)) ||
                nft.getApproved(tokenId) == address(this),
            "Marketplace not approved"
        );
        uint256 listingId = listingCounter++;
        listings[listingId] = Listing({
            seller: msg.sender,
            ntfContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });

        emit NFTListed(listingId, msg.sender, nftContract, tokenId, price);
        return listingId;
    }

    function buyNFT(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(
            msg.sender != listing.seller,
            "Seller cannot buy their own NFT"
        );

        // Mark listing as inactive
        listing.active = false;

        // Transfer payment from buyer to seller
        require(
            paymentToken.transferFrom(
                msg.sender,
                listing.seller,
                listing.price
            ),
            "Payment transfer failed"
        );

        // Transfer NFT from seller to buyer
        IERC721 nft = IERC721(listing.ntfContract);
        nft.safeTransferFrom(listing.seller, msg.sender, listing.tokenId);

        emit NFTPurchased(listingId, msg.sender, listing.seller, listing.price);
    }

    function tokenReceived(
        address from,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bool) {
        require(
            msg.sender == address(paymentToken),
            "Unauthorized token receiver"
        );
        require(data.length == 32, "Invalid data length");

        uint256 listingId = abi.decode(data, (uint256));
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(from != listing.seller, "Seller cannot buy their own NFT");
        require(amount == listing.price, "Incorrect payment amount");

        // Mark listing as inactive
        listing.active = false;

        require(
            paymentToken.transfer(listing.seller, amount),
            "Payment transfer failed"
        );

        // Transfer NFT from seller to buyer
        IERC721 nft = IERC721(listing.ntfContract);
        nft.safeTransferFrom(listing.seller, from, listing.tokenId);

        emit NFTPurchased(listingId, from, listing.seller, amount);

        return true;
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing is not active");
        require(listing.seller == msg.sender, "Only seller can cancel listing");

        listing.active = false;
        emit ListingCancelled(listingId);
    }

    function getListing(
        uint256 listingId
    ) external view returns (Listing memory) {
        return listings[listingId];
    }
}
