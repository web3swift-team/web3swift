pragma solidity ^0.4.23;

import "../../Helpers/TokenBasics/StandardToken.sol";

contract web3swift is StandardToken {
  string public constant NAME = "web3swift";
  string public constant SYMBOL = "w3s";
  uint256 public constant DECIMALS = 18;

  uint256 public constant INITIAL_SUPPLY = 500000000 * 10**18;

  /**
   * @dev Create and issue tokens to msg.sender.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}