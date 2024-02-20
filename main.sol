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

    event PropertyAdded(uint256 tokenId, string name, string leaseDetails);
    event PropertyTransferred(uint256 tokenId, address from, address to);
    event PropertyBurned(uint256 tokenId);

    constructor() ERC721("RealEstateNFT", "RENT") {
        _mint(msg.sender, 1);
    }

    // Mint a token to the owner
    function mint() public payable {
        _mint(msg.sender, totalSupply() + 1);
    }

    function addProperty(
        string memory name,
        string memory leaseDetails
    ) public onlyOwner {
        require(bytes(name).length > 0, "Property name cannot be empty");
        require(
            bytes(leaseDetails).length > 0,
            "Lease details cannot be empty"
        );

        uint256 tokenId = totalSupply() + 1;
        properties[tokenId] = Property(name, msg.sender, leaseDetails);
        _mint(msg.sender, tokenId);

        emit PropertyAdded(tokenId, name, leaseDetails);
    }

    function getProperty(
        uint256 tokenId
    ) public view returns (Property memory) {
        require(_exists(tokenId), "Property does not exist.");
        return properties[tokenId];
    }

    event PropertyTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );

    function transferProperty(uint256 tokenId, address newOwner) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can transfer.");
        require(
            newOwner != address(0),
            "New owner cannot be the zero address."
        );

        _transfer(msg.sender, newOwner, tokenId);
        properties[tokenId].owner = newOwner;

        emit PropertyTransferred(tokenId, msg.sender, newOwner);
    }

    event PropertyBurned(uint256 indexed tokenId);

    function burnProperty(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can burn.");
        _burn(tokenId);
        delete properties[tokenId]; // This removes the property from the mapping.

        emit PropertyBurned(tokenId);
    }
}
