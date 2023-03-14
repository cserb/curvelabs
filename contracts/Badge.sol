// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

contract Badge is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  mapping (address => uint256) public tokenBalanceOf;
  mapping (address => uint256) public timestamp;

  IERC20 public lpTokenContract;

  constructor(IERC20 _lpTokenContract) ERC721("Badge", "LPB") {
    lpTokenContract = _lpTokenContract;
  }

  function stake(uint256 amount) external {
    require(amount > 0, "amount <= 0");
    lpTokenContract.transferFrom(msg.sender, address(this), amount);

    tokenBalanceOf[msg.sender] += amount;
    timestamp[msg.sender] = block.timestamp;
  }

  function unstake(uint256 amount) external {
    require(amount > 0, "amount <= 0");
    lpTokenContract.transfer(msg.sender, amount);

    tokenBalanceOf[msg.sender] -= amount;
  }

  function claim() external {
    require(tokenBalanceOf[msg.sender] > 0, "Nothing staked");
    require(balanceOf(msg.sender) == 0, "Already claimed");

    uint256 timeFrame = 1 weeks;
    uint256 timeDiff = block.timestamp - timestamp[msg.sender];
    require(timeDiff > timeFrame, "Claiming too soon");

    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, "Level 1");

    _tokenIds.increment();
  }
}
