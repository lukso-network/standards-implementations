const Identity = artifacts.require("Identity");

contract("Identity", accounts => {
  context("Identity Deployment", async () => {
    it("Deploys correctly", async () => {
      const owner = accounts[2];
      const identity = await Identity.new();
      console.log(identity);
    });
  });
});
