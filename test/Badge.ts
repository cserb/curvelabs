import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { utils } from "ethers";

describe("Badge", function () {
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, lpAcc] = await ethers.getSigners();

    const LPToken = await ethers.getContractFactory("LPToken")
    const lpToken = await LPToken.deploy();

    const Badge = await ethers.getContractFactory("Badge");
    const badge = await Badge.deploy(lpToken.address);

    return { owner, lpAcc, lpToken, badge };
  }

  describe("Happy path in a perfect world", function () {
    it("Should run smoothly", async function () {
      const { badge, lpAcc, lpToken } = await loadFixture(deploy);
      const amount = utils.parseUnits("1000", 18);

      // get some tokens
      await lpToken.connect(lpAcc).mintTokens(amount);
      expect(await lpToken.balanceOf(lpAcc.address)).to.equal(amount);

      // stake tokens
      await lpToken.connect(lpAcc).approve(badge.address, amount);
      await badge.connect(lpAcc).stake(amount);
      expect(await badge.tokenBalanceOf(lpAcc.address)).to.equal(amount);
      expect(await lpToken.balanceOf(lpAcc.address)).to.equal(0);
      expect(await lpToken.balanceOf(badge.address)).to.equal(amount);

      // claim badge
      time.increase(691200);
      await badge.connect(lpAcc).claim();
      expect(await badge.balanceOf(lpAcc.address)).to.equal(1);
      expect(await badge.tokenURI(0)).to.equal("Level 1");

      // unstake
      await badge.connect(lpAcc).unstake(amount);
      expect(await badge.tokenBalanceOf(lpAcc.address)).to.equal(0);
      expect(await lpToken.balanceOf(lpAcc.address)).to.equal(amount);
      expect(await lpToken.balanceOf(badge.address)).to.equal(0);
    });
  });
});
