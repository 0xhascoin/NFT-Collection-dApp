// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    string _baseTokenUri;
    uint public _price = 0.01 ether; // The price of one crypto dev nft
    bool public _paused; // Used to pause the contract incase of an emergency
    uint256 public maxTokenIds = 20; // Max number of Crypto dev NFTs
    uint256 public tokenIds; // Total number of tokens minted

    IWhitelist whitelist; // Whitelist contract instance
    bool public presaleStarted; // Tracks if the presale started or not
    uint256 public presaleEnded; // Timestamp for when presale ended

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused.");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
        _baseTokenUri = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    // Starts a presale for the whitelisted addresses
    function startPresale() public onlyOwner {
        presaleStarted = true; // Start the presale
        presaleEnded = block.timestamp + 5 minutes; // Set te presale ended time to current time + 5 mins
    }

    // Allows user to mint 1 NFT per transaction during the presale
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running."); // Make sure the presale has started and its before the end of the presale time
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted."); // Make sure the caller is in the whitelist
        require(tokenIds < maxTokenIds, "Exceeded max Crypto Devs supply"); // Make sure that there is less than the max tokens minted
        require(msg.value >= _price, "Ether sent is not correct"); // Make sure that the amount sent is equal to or greater than the price of the NFT
        tokenIds += 1; // Increment the amount of tokens minted
        _safeMint(msg.sender, tokenIds); // Mint the NFT
    }

    // Allows user to mint 1 NFT per transaction after the presale
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet"); // Make sure that the presale has ended
        require(tokenIds < maxTokenIds, "Exceeded max Crypto Dev supply"); // Make sure that there are still NFTs available to mint
        require(msg.value >= _price, "Ether sent is not correct"); // Make sure that the amount of ether sent is more or equal to the price of the NFT
        tokenIds += 1; // Increment the amount of tokens minted
        _safeMint(msg.sender, tokenIds); // Mint the NFT
    }

    // Gets the base token uri
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenUri;
    }

    // Makes the contract paused or unpaused
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // Sends all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner {
        address _owner = owner(); // The address of the owner of the contract
        uint256 amount = address(this).balance; // Gets the balance of this contract
        (bool sent, ) = _owner.call{value: amount}(""); // Sends the amount to the owners address and returns if it was successfull or not
        require(sent, "Failed to send ether"); // Makes sure that the amount was sent succesfully
    }

    // Receives ether
    receive() external payable {}

    fallback() external payable {}
}