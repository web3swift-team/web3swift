pragma solidity ^0.4.24;

import "../Helpers/TokenBasics/ERC20.sol";

contract Web3SwiftToken is ERC20 {

  string public constant name = "Web3Swift";
  string public constant symbol = "W3S";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    _mint(msg.sender, INITIAL_SUPPLY);
  }

