// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LPToken is ERC20 {
  using SafeMath for uint256;

  constructor() ERC20("LP Token", "LPT") {}

  function mintTokens(uint _numberOfTokens) external {
    _mint(msg.sender, _numberOfTokens);
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

}

