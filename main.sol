// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RealEstateNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    struct Property {
        string name;
        string leaseDetails;
    }

    mapping(uint256 => Property) public properties;
    mapping(string => bool) private propertyExists;

    event PropertyAdded(
        uint256 indexed tokenId,
        string name,
        string leaseDetails
    );
    event PropertyTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );
    event PropertyBurned(uint256 indexed tokenId);

    constructor() ERC721("RealEstateNFT", "RENT") {}

    // Removed the mint function to ensure properties are added with details and controlled by the owner

    /**
     * @dev Add a new property, minting a token and setting its details.
     * Only callable by the contract owner.
     */
    function addProperty(
        string memory name,
        string memory leaseDetails
    ) public onlyOwner {
        require(bytes(name).length > 0, "Property name cannot be empty");
        require(
            bytes(leaseDetails).length > 0,
            "Lease details cannot be empty"
        );
        require(!propertyExists[name], "Property already exists");

        uint256 tokenId = totalSupply() + 1;
        properties[tokenId] = Property(name, leaseDetails);
        propertyExists[name] = true;
        _mint(msg.sender, tokenId);

        emit PropertyAdded(tokenId, name, leaseDetails);
    }

    /**
     * @dev Retrieve property details by token ID.
     */
    function getProperty(
        uint256 tokenId
    ) public view returns (Property memory) {
        require(_exists(tokenId), "Property does not exist.");
        return properties[tokenId];
    }

    /**
     * @dev Transfer property to a new owner, updating the internal mapping.
     * Can only be called by the current owner of the token.
     */
    function transferProperty(
        uint256 tokenId,
        address newOwner
    ) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can transfer.");
        require(
            newOwner != address(0),
            "New owner cannot be the zero address."
        );

        _transfer(msg.sender, newOwner, tokenId);
        emit PropertyTransferred(tokenId, msg.sender, newOwner);
    }

    /**
     * @dev Burn a property token, removing its details.
     * Can only be called by the current owner of the token.
     */
    function burnProperty(uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can burn.");
        _burn(tokenId);
        delete properties[tokenId];
        emit PropertyBurned(tokenId);
    }
}
