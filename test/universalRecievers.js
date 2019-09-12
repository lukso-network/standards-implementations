const UniReciever = artifacts.require("UniReciever");
const Checker = artifacts.require("Checker");
// const ExternalReciever = artifacts.require("ExternalReciever");
// const DelegateReciever = artifacts.require("DelegateReciever");
// const BasicBareReciever = artifacts.require("BasicBareReciever");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Recievers", accounts => {
  let uni = {};
  const token_interface =
    "0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b";
  beforeEach(async () => {
    uni = await UniReciever.new();
  });
  it("Can check for implementing interface", async () => {
    const token_interface =
      "0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b";
    let tx = await uni.universalReciever(token_interface, "0x");
    console.log(
      "Directly checking for implementing interface costs: ",
      tx.receipt.gasUsed
    );
    let res = await uni.universalReciever.call(token_interface, "0x");
    assert.equal(res, token_interface);
  });

  it("Contract can check for implementing interface", async () => {
    let checker = await Checker.new();
    let tx = await checker.checkImplementation(uni.address, token_interface);
    console.log(
      "Contract checking for implementing interface costs: ",
      tx.receipt.gasUsed
    );
    let res = await checker.checkImplementation.call(
      uni.address,
      token_interface
    );
    assert.isTrue(res);
  });
});
