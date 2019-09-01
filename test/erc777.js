const ERC777Striped = artifacts.require("ERC777Striped");
const ERC777 = artifacts.require("ERC777");
const ERC1820Registry = artifacts.require("ERC1820Registry");
const RecievingAccount = artifacts.require("RecievingAccount");
const ERC777Reciever = artifacts.require("ERC777Reciever");

const { expectRevert, expectEvent } = require("openzeppelin-test-helpers");

contract("ERC777", accounts => {
  context("Using Regular ECR777", async () => {
    const owner = accounts[9];
    const TOKEN_RECIPIENT =
      "0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b";
    let registry, account, reciever;
    erc777 = {};
    before(async () => {
      console.log("Testing ERC77 + Account + Universal Reciever");
      console.log(
        "An address transfer ERC77 to an Account that has a UniversalReciever configured"
      );
    });
    beforeEach(async () => {
      registry = await ERC1820Registry.new();
      account = await RecievingAccount.new({ from: owner });
      reciever = await ERC777Reciever.new();

      await account.changeReciever(reciever.address, {
        from: owner
      });
      let data = web3.eth.abi.encodeFunctionCall(
        {
          name: "setInterfaceImplementer",
          type: "function",
          inputs: [
            {
              type: "address",
              name: "_addr"
            },
            {
              type: "bytes32",
              name: "_interfaceHash"
            },
            {
              type: "address",
              name: "_implementer"
            }
          ]
        },
        [account.address, TOKEN_RECIPIENT, account.address]
      );
      await account.execute(0, registry.address, 0, data, { from: owner });
      erc777 = await ERC777.new("ERC", "777", [], registry.address);
    });
    it("Deploys correctly", async () => {
      let impl = await registry.getInterfaceImplementer(
        account.address,
        TOKEN_RECIPIENT
      );
      assert.equal(impl, account.address);
    });
    it("Transfer correctly between regular addresses", async () => {
      const reciever = accounts[1];
      let initBal = await erc777.balanceOf(reciever);
      let tx1 = await erc777.transfer(reciever, 500);
      console.log(
        "Gas used for `transfer` function between regular addresses: ",
        tx1.receipt.gasUsed
      );
      let tx2 = await erc777.send(reciever, 500, "0x");
      console.log(
        "Gas used for `send` function between regular addresses: ",
        tx2.receipt.gasUsed
      );
      let finBal = await erc777.balanceOf(reciever);
      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Accepts correctly for implementing interface", async () => {
      const reciever = account.address;
      let initBal = await erc777.balanceOf(reciever);
      let tx = await erc777.send(reciever, 500, "0x");
      console.log(
        "Gas Used for calling 'send' to implementing interface: ",
        tx.receipt.gasUsed
      );
      let finBal = await erc777.balanceOf(reciever);
      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Rejects correctly for implementing interface", async () => {
      const reciever = await RecievingAccount.new();
      await expectRevert(
        erc777.send(reciever.address, 500, "0x"),
        "ERC777: token recipient contract has no implementer for ERC777TokensRecipient"
      );
    });

    it("Forcefully send regardless of interface", async () => {
      const reciever = await RecievingAccount.new();
      let initBal = await erc777.balanceOf(reciever.address);
      let tx = await erc777.transfer(reciever.address, 500);
      console.log(
        "Gas Used for calling 'trasnfer to implementing interface: ",
        tx.receipt.gasUsed
      );
      let finBal = await erc777.balanceOf(reciever.address);
      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
  }); //context

  context("Using Stripped ERC777", async () => {
    const owner = accounts[9];
    const TOKEN_RECIPIENT =
      "0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b";
    let account,
      reciever,
      erc777striped = {};
    before(async () => {
      console.log(
        "Testing the strripped ERC77(without 1820) + Account + Universal Reciever"
      );
      console.log(
        "An address transfer ERC77 to an Account that has a UniversalReciever configured"
      );
    });
    beforeEach(async () => {
      erc777striped = await ERC777Striped.new("ERC", "777", [accounts[0]]);
      account = await RecievingAccount.new({ from: owner });
      reciever = await ERC777Reciever.new();
      await account.changeReciever(reciever.address, {
        from: owner
      });
    });

    it("Deploys correctly", async () => {});
    it("Transfer correctly between regular addresses", async () => {
      const reciever = accounts[1];
      let initBal = await erc777striped.balanceOf(reciever);
      let tx1 = await erc777striped.transfer(reciever, 500);
      console.log(
        "gas used for calling 'transfer' function between addresses: ",
        tx1.receipt.gasUsed
      );

      let tx2 = await erc777striped.send(reciever, 500, "0x");
      console.log(
        "gas used for calling 'send' function between addresses:  ",
        tx2.receipt.gasUsed
      );
      let finBal = await erc777striped.balanceOf(reciever);
      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Accepts correctly for implementing interface", async () => {
      const reciever = account.address;
      let initBal = await erc777striped.balanceOf(reciever);
      let tx = await erc777striped.send(reciever, 500, "0x");
      console.log(
        "gas used for calling 'send' function to implementing interface: ",
        tx.receipt.gasUsed
      );
      let finBal = await erc777striped.balanceOf(reciever);

      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Rejects correctly for implementing interface", async () => {
      const reciever = await RecievingAccount.new();
      await expectRevert(
        erc777striped.send(reciever.address, 500, "0x"),
        "ERC777: token recipient contract has no implementer for ERC777TokensRecipient"
      );
    });

    it("Forcefully send regardless of interface", async () => {
      const reciever = await RecievingAccount.new();
      let initBal = await erc777striped.balanceOf(reciever.address);
      let tx = await erc777striped.transfer(reciever.address, 500);
      console.log(
        "gas used for calling 'transfer' function to non-implementing contract: ",
        tx.receipt.gasUsed
      );
      let finBal = await erc777striped.balanceOf(reciever.address);
      assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
  });
});
