// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Ruochen NFT
/// @notice Simple ERC721 contract where the owner can mint NFTs with a tokenURI
contract Ruochen is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    constructor() ERC721("Ruochen", "RC") Ownable(msg.sender) {}

    /// @notice Mint a new token to `to` with metadata `tokenURI`
    /// @dev Only the contract owner can call this. Token IDs start from 1.
    /// @param to recipient of the minted NFT
    /// @param tokenURI metadata URI for the token
    /// @return tokenId the newly minted token ID
    function mint(address to, string memory tokenURI) external onlyOwner returns (uint256) {
        require(to != address(0), "Ruochen: invalid recipient");
        require(bytes(tokenURI).length > 0, "Ruochen: tokenURI required");

        _tokenIds++;
        uint256 tokenId = _tokenIds;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}
