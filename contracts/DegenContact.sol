// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "hardhat/console.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {
     constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        // Pre-listing items in the constructor
        addItem("Cap", 100);
        addItem("Bat", 150);
        addItem("Shirt", 200);
    }

    // Item struct to store name and price
    struct Item {
        string name;
        uint256 price;
    }

    // List of items for sale
    Item[] public items;

    // Event emitted when a user buys an item
    event ItemPurchased(address indexed buyer, uint256 itemId, string itemName, uint256 price);

    // Function to add items to the shop 
    function addItem(string memory name, uint256 price) public onlyOwner {
        items.push(Item(name, price));
    }

    // Function to view an item's price
    function getItemPrice(uint256 itemId) external view returns (uint256) {
        require(itemId < items.length, "Item does not exist");
        return items[itemId].price;
    }

    // Function to purchase an item 
    function purchaseItem(uint256 itemId) external { 
        require(itemId < items.length, "Item does not exist"); 
        Item memory item = items[itemId]; // Ensure the buyer has enough tokens 
        uint256 buyerBalance = balanceOf(msg.sender); 
        require(buyerBalance >= item.price, "Insufficient tokens to purchase this item"); 
        // Transfer tokens directly from buyer to contract 
        bool success = transfer(address(this), item.price); 
        require(success, "Token transfer failed"); 
        // Emit an event for the purchase 
        emit ItemPurchased(msg.sender, itemId, item.name, item.price); 
        }

    // Function to allow the owner to withdraw tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient contract balance");
        transfer(owner(), amount);
    }

    // Only the owner can mint new tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // decimals
    function decimals() override public pure returns (uint8) {
        return 18;  // No decimals
    }

    // Any user can burn their tokens
    function burn(uint256 amount) override public {
        _burn(msg.sender, amount);
    }

    // get balance
    function getBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }
}
