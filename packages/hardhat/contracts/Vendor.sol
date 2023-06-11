pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event Withdrawal(address, uint256);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfEth = msg.value;
    require(amountOfEth > 0, "Need to buy some tokens");

    uint256 amountOfTokens = amountOfEth * tokensPerEth;
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountOfTokens, "Vendor is short on tokens!");

    address buyer = msg.sender;
    (bool sent) = yourToken.transfer(buyer, amountOfTokens);
    require(sent, "Failed to transfer tokens");

    emit BuyTokens(buyer, amountOfEth, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public payable onlyOwner { 
    uint256 vendorBalance = address(this).balance;
    require(vendorBalance > 0, "Vendor does not have any ETH to withdraw");

    address owner = msg.sender;
    (bool sent, ) = owner.call{value: vendorBalance}("");

    emit Withdrawal(owner, vendorBalance);
  } 

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 amount) public {
    require(amount > 0, "Must sell some tokens");
  
    address seller = msg.sender;
    uint256 sellerBalance = yourToken.balanceOf(seller);
    uint256 vendorBalance = address(this).balance;

    require(sellerBalance >= amount, "Cant withdraw that many tokens");
    uint256 EthToReturn = amount / tokensPerEth;
    require(vendorBalance > EthToReturn, "Not Enough ETH in Vendor Wallet");

    (bool sent) = yourToken.transferFrom(seller, address(this), amount);
    require(sent, "Failed to transfer tokens");

    (bool ethSent, ) = seller.call{value: EthToReturn}("");
    require(ethSent, "Failed to send back ETH");

    emit SellTokens(seller, EthToReturn, amount);
  }

}
