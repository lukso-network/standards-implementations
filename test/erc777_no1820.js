const ERC777UniversalReceiver = artifacts.require("ERC777UniversalReceiver_no1820");
const ReceivingAccount = artifacts.require("Account");
const ERC777Receiver = artifacts.require("ERC777Receiver");

const {expectRevert, singletons} = require("openzeppelin-test-helpers");

// Get key: keccak256('LSP1UniversalReceiverAddress')
const UNIVERSALRECEIVER_KEY = '0x8619f233d8fc26a7c358f9fc6d265add217d07469cf233a61fc2da9f9c4a3205';

contract("ERC777", accounts => {
    context("Using Stripped ERC777", async () => {
        const owner = accounts[9];

        let account,
            receiver,
            erc777 = {};
        before(async () => {
            console.log(
                "Testing the strripped ERC77(without 1820) + Account + Universal Receiver"
            );
            console.log(
                "An address transfer ERC77 to an Account that has a UniversalReceiver configured"
            );
        });
        beforeEach(async () => {
            erc777 = await ERC777UniversalReceiver.new("MyToken", "TKN", [accounts[0]]);
            account = await ReceivingAccount.new(owner, {from: owner});
            receiver = await ERC777Receiver.new();
            await account.setData(UNIVERSALRECEIVER_KEY, receiver.address, {
                from: owner
            });
        });

        it("Transfer correctly between regular addresses", async () => {
            const receiver = accounts[1];
            let initBal = await erc777.balanceOf(receiver);
            let tx1 = await erc777.transfer(receiver, 500);
            console.log(
                "gas used for calling 'transfer' function between addresses: ",
                tx1.receipt.gasUsed
            );

            let tx2 = await erc777.send(receiver, 500, "0x");
            console.log(
                "gas used for calling 'send' function between addresses:  ",
                tx2.receipt.gasUsed
            );
            let finBal = await erc777.balanceOf(receiver);
            assert.isTrue(finBal.toNumber() > initBal.toNumber());
        });
        it("Accepts correctly for implementing interface", async () => {
            const receiver = account.address;
            let initBal = await erc777.balanceOf(receiver);
            let tx = await erc777.send(receiver, 500, "0x");
            console.log(
                "gas used for calling 'send' function to implementing interface: ",
                tx.receipt.gasUsed
            );
            let finBal = await erc777.balanceOf(receiver);

            assert.isTrue(finBal.toNumber() > initBal.toNumber());
        });
        it("Rejects correctly for implementing interface", async () => {
            const receiver = await ReceivingAccount.new();
            await expectRevert(
                erc777.send(receiver.address, 500, "0x"),
                "ERC777: token recipient contract has no implementer for ERC777TokensRecipient"
            );
        });

        it("Forcefully send regardless of interface", async () => {
            const receiver = await ReceivingAccount.new();
            let initBal = await erc777.balanceOf(receiver.address);
            let tx = await erc777.transfer(receiver.address, 500);
            console.log(
                "gas used for calling 'transfer' function to non-implementing contract: ",
                tx.receipt.gasUsed
            );
            let finBal = await erc777.balanceOf(receiver.address);
            assert.isTrue(finBal.toNumber() > initBal.toNumber());
        });
    });
});
