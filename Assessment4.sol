// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DegenToken {
    address public tokenOwner;
    string public tokenName;
    string public tokenSymbol;
    uint8 public decimals;
    uint256 public totalSupply;

    constructor() {
        tokenOwner = msg.sender;
        tokenName = "Degen";
        tokenSymbol = "DGN";
        decimals = 10;
        totalSupply = 0;
    }

    modifier ownerOnly() {
        require(msg.sender == tokenOwner, "This function can only be used by the owner.");
        _;
    }

    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private allowances;
    NFT[] public NFTaccs;

    struct NFT {
        string name;
        uint256 price;
    }

    function storeNFTAccessory(string memory itemName, uint256 itemPrice) public ownerOnly {
        NFT memory newNFT = NFT(itemName, itemPrice);
        NFTaccs.push(newNFT);
    }

    event Mint(address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Redeem(address indexed from, string itemName);

    function mintToken(address to, uint256 amount) external ownerOnly {
        totalSupply += amount;
        balance[to] += amount;

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function balanceOf(address accountAddress) external view returns (uint256) {
        return balance[accountAddress];
    }

    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }


    function transferToken(address receiver, uint256 amount) external returns (bool) {
        require(balance[msg.sender] >= amount, "Kindly enter an amount lower than or equal to your balance.");

        balance[msg.sender] -= amount;
        balance[receiver] += amount;

        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 amount) external returns (bool) {
        require(balance[msg.sender] >= amount, "Kindly enter an amount lower than or equal to your balance.");
        require(allowances[sender][msg.sender] >= amount, "Kindly enter an amount lower than or equal to your balance.");

        balance[sender] -= amount;
        balance[receiver] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, receiver, amount);
        return true;
    }

    function burnToken(uint256 amount) external {
        require(amount <= balance[msg.sender], "Kindly enter an amount lower than or equal to your balance.");

        balance[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function redeemItem(uint256 accId) external returns (string memory) {
        require(balance[msg.sender] > 0, "Balance is very low and unredeemable.");
        require(accId < NFTaccs.length, "Invalid item ID.");

        uint256 redemptionAmount = NFTaccs[accId].price;
        require(balance[msg.sender] >= redemptionAmount, "Balance should be equal to or more than the item to redeem it.");

        balance[msg.sender] -= redemptionAmount;

        emit Redeem(msg.sender, NFTaccs[accId].name);

        return NFTaccs[accId].name;
    }
}
