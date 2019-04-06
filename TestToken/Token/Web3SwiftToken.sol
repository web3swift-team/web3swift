pragma solidity ^0.4.24;

import "../Helpers/TokenBasics/ERC20.sol";

contract web3swift is ERC20 {

  string public constant name = "web3swift";
  string public constant symbol = "w3s";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 1024 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    _mint(msg.sender, INITIAL_SUPPLY);
  }

