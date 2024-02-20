// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateNFT is ERC721Enumerable, Ownable {
    struct Property {
        string name;
        address owner;
        string leaseDetails; // Simplified for demonstration
    }

    mapping(uint256 => Property) public properties;
}

constructor() ERC721("RealEstateNFT", "RENT") {
    _mint(msg.sender, 1);
}

// Mint a token to the owner

function addProperty(
    string memory name,
    string memory leaseDetails
) public onlyOwner {
    uint256 tokenId = totalSupply() + 1;
    properties[tokenId] = Property(name, msg.sender, leaseDetails);
    _mint(msg.sender, tokenId);
}

function getProperty(uint256 tokenId) public view returns (Property memory) {
    require(_exists(tokenId), "Property does not exist.");
    return properties[tokenId];
}

function transferProperty(uint256 tokenId, address newOwner) public {
    require(ownerOf(tokenId) == msg.sender, "Only the owner can transfer.");
    _transfer(msg.sender, newOwner, tokenId);
    properties[tokenId].owner = newOwner;
}

function burnProperty(uint256 tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "Only the owner can burn.");
    _burn(msg.sender, tokenId);
    properties[tokenId].owner = address(0);
}
