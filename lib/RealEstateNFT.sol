// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Declare custom errors
error OnlyOwnerCanTransfer();
error InvalidNewOwner();
error PropertyDoesNotExist();
error PropertyAlreadyExists();
error InvalidInput();
error OnlyOwnerCanBurn();

contract RealEstateNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct Property {
        string name;
        string leaseDetails;
    }

    mapping(uint256 => Property) public properties;
    mapping(string => bool) private propertyExists;

    // Events
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

    // The _beforeTokenTransfer hook does not need to accept a _data parameter as it's not used.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Add a new property, minting a token and setting its details.
    function addProperty(
        string memory name,
        string memory leaseDetails
    ) public onlyOwner {
        if (propertyExists[name]) revert PropertyAlreadyExists();
        if (bytes(name).length == 0 || bytes(leaseDetails).length == 0)
            revert InvalidInput();

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        properties[tokenId] = Property(name, leaseDetails);
        propertyExists[name] = true;

        _mint(msg.sender, tokenId);
        emit PropertyAdded(tokenId, name, leaseDetails);
    }

    // Retrieve property details by token ID.
    function getProperty(
        uint256 tokenId
    ) public view returns (Property memory) {
        if (!_exists(tokenId)) revert PropertyDoesNotExist();
        return properties[tokenId];
    }

    // Transfer property to a new owner, updating the internal mapping.
    function transferProperty(
        uint256 tokenId,
        address newOwner
    ) public nonReentrant {
        if (ownerOf(tokenId) != msg.sender) revert OnlyOwnerCanTransfer();
        if (newOwner == address(0)) revert InvalidNewOwner();

        _transfer(msg.sender, newOwner, tokenId);
        emit PropertyTransferred(tokenId, msg.sender, newOwner);
    }

    // Burn a property token, removing its details.
    function burnProperty(uint256 tokenId) public nonReentrant {
        if (ownerOf(tokenId) != msg.sender) revert OnlyOwnerCanBurn();
        if (!_exists(tokenId)) revert PropertyDoesNotExist();

        _burn(tokenId);
        delete properties[tokenId];
        emit PropertyBurned(tokenId);
    }
}
