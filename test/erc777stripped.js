const ERC777Striped = artifacts.require("ERC777Striped");
const ERC777 = artifacts.require("ERC777");
const ERC1820Registry = artifacts.require("ERC1820Registry");

contract("ERC777Striped", accounts => {
  let registry,
    erc777,
    erc777striped = {};
  beforeEach(async () => {
    registry = await ERC1820Registry.new();
  });
  it("Deploys correctly", async () => {
    erc777striped = await ERC777Striped.new("ERC", "777", [accounts[0]]);
    erc777 = await ERC777.new("ERC", "777", [], registry.address);
  });

  it("works correctly between pure accounts", async () => {
    const reciever = accounts[2];
    let initBal = await erc777striped.balanceOf(reciever);
    await erc777striped.transfer(accounts[2], 500);
    let finBal = await erc777striped.balanceOf(reciever);
    assert.isTrue(finBal.toNumber() > initBal.toNumber());
  });

  it("Transfer tokens correctly for implementing interface", async () => {});
  it("Doesn fail for non-implementing contracts", async () => {});
});
