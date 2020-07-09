const ERC777UniversalReceiver_1820 = artifacts.require("ERC777UniversalReceiver_1820");
const Account = artifacts.require("Account");
const PlainERC725Account = artifacts.require("ERC725Account");
const ExternalERC777UniversalReceiverTester = artifacts.require("ExternalERC777UniversalReceiverTester");
const ExternalERC777UniversalReceiverRejectTester = artifacts.require("ExternalERC777UniversalReceiverRejectTester");

const {expectRevert, singletons} = require("openzeppelin-test-helpers");

// Get key: keccak256('LSP1UniversalReceiverAddress')
const UNIVERSALRECEIVER_KEY = '0x8619f233d8fc26a7c358f9fc6d265add217d07469cf233a61fc2da9f9c4a3205';
const TOKENS_RECIPIENT_INTERFACE_HASH = "0x2352f13a810c120f366f70972476f743e16a9f2196b4b60037b84185ecde66d3"; // keccak256("LSP1_ERC777TokensRecipient")
const OPERATION_CALL = 0;

contract("ERC777", accounts => {
    let erc1820;
    beforeEach(async function () {
        erc1820 = await singletons.ERC1820Registry(accounts[1]);
    });

    context("Using 1820 ERC777", async () => {
        const owner = accounts[9];

        let account,
            erc777 = {};
        before(async () => {
            console.log(
                "Testing the ERC77 without 1820 + Accounts + Universal Receiver"
            );
            console.log(
                "An address transfer ERC77 to an Accounts that has a UniversalReceiver configured"
            );
        });
        beforeEach(async () => {
            erc777 = await ERC777UniversalReceiver_1820.new("MyToken", "TKN", [accounts[0]]);
            await erc777.mint('100000000', {from: accounts[0]});
            account = await Account.new(owner, {from: owner});

            // set ERC1820 implementer
            const callData = erc1820.contract.methods.setInterfaceImplementer(account.address, TOKENS_RECIPIENT_INTERFACE_HASH, account.address).encodeABI();
            account.execute(OPERATION_CALL, erc1820.address, 0, callData, {from: owner});
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
        it("Send to account implementing universal receiver", async () => {
            let initBal = await erc777.balanceOf(account.address);
            let tx = await erc777.send(account.address, 500, "0x");
            console.log(
                "gas used for calling 'send' function to implementing interface: ",
                tx.receipt.gasUsed
            );
            let finBal = await erc777.balanceOf(account.address);

            assert.isTrue(finBal.toNumber() > initBal.toNumber());
        });
        it("Rejects account not implementing universal receiver", async () => {
            const receiver = await PlainERC725Account.new(accounts[0]);
            await expectRevert(
                erc777.send(receiver.address, 500, "0x"),
                "ERC777: token recipient contract has no universal receiver for 'LSP1_ERC777TokensRecipient'"
            );
        });
        it("Send to account delegating universal receiver to another smart contract", async () => {
            let externalUniversalReceiver = await ExternalERC777UniversalReceiverTester.new();
            await account.setData(UNIVERSALRECEIVER_KEY, externalUniversalReceiver.address, {
                from: owner
            });

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
        it("Send to account where the delegating universal receiver will reject it", async () => {
            let externalUniversalReceiver = await ExternalERC777UniversalReceiverRejectTester.new();
            await account.setData(UNIVERSALRECEIVER_KEY, externalUniversalReceiver.address, {
                from: owner
            });

            await expectRevert(
                erc777.send(account.address, 500, "0x"),
                "We reject everything"
            );
        });

        it("Forcefully send regardless of interface (using ERC20 transfer)", async () => {
            const receiver = await PlainERC725Account.new(accounts[0]);
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
