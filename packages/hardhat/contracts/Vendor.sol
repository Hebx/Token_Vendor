pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {


  YourToken public yourToken;

  uint256 public tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfEth);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
  /**
  * @notice allow users to buy token per ETH
  */
  function buyTokens() public payable returns (uint256 tokenAmount)
  {
    require(msg.value > 0, "Send ETH to buy some tokens");
    uint256 amountToBuy = msg.value * tokensPerEth;

    // check if the vendor contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    // transfer token to the msg.sender
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to the user");

    emit BuyTokens(msg.sender, msg.value, amountToBuy);
    return amountToBuy;
  }


  /**
  * @notice Allow users to sell tokens for ETH
  */
  function sellTokens(uint256 tokenAmountToSell) public {

    // check that the requested amount of tokens to sell is more than 0
    require(tokenAmountToSell > 0, "specify an amount of token greater than zero");

    // check that the user's token balance is enough to do swap
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

    // check that the vendor's token balance is enough to do swap
    uint256 amountOfEthToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerEthBalance = address(this).balance;
    require(ownerEthBalance >= amountOfEthToTransfer, "Vendor has not enough funds to accept the sell request");

// his operation can succeed only if the user has already approved at least that specific amount
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");

//  ETH amount for the sell operation back to the user’s address.
    (sent,) = msg.sender.call{value: amountOfEthToTransfer}("");
    require(sent, "Failed to send ETH to the user");
  }

  /**
  * @notice allow users to buy token per ETH
  */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner balance is empty");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }


}
