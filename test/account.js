const Account = artifacts.require("Account");
const KeyManager = artifacts.require("SimpleKeyManager");
const {BN, ether, expectRevert} = require("openzeppelin-test-helpers");

contract("Account", accounts => {
    context("Account Deployment", async () => {
        it("Deploys correctly", async () => {
            const owner = accounts[2];
            const account = await Account.new({from: owner});

            const idOwner = await account.owner.call();

            assert.equal(idOwner, owner, "Addresses should match");
        });
    });

    context("Interactions with Account contracts", async () => {
        const owner = accounts[3];
        const newOwner = accounts[5];
        let account = {};

        beforeEach(async () => {
            account = await Account.new({from: owner});
        });

        it("Uprade ownership correctly", async () => {
            await account.changeOwner(newOwner, {from: owner});
            const idOwner = await account.owner.call();

            assert.equal(idOwner, newOwner, "Addresses should match");
        });

        it("Refuse upgrades from non-onwer", async () => {
            await expectRevert(
                account.changeOwner(newOwner, {from: newOwner}),
                "only-owner-allowed"
            );
        });

        it("Owner can set data", async () => {
            const key = web3.utils.asciiToHex("Important Data");
            const data = web3.utils.asciiToHex("Important Data");

            await account.setData(key, data, {from: owner});

            let fetchedData = await account.getData(key);

            assert.equal(data, fetchedData);
        });

        it("Fails when non-owner sets data", async () => {
            const key = web3.utils.asciiToHex("Important Data");
            const data = web3.utils.asciiToHex("Important Data");

            await expectRevert(
                account.setData(key, data, {from: newOwner}),
                "only-owner-allowed"
            );
        });

        it("Allows owner to execute calls", async () => {
            const dest = accounts[6];
            const amount = ether("10");
            const OPERATION_CALL = 0x0;

            await web3.eth.sendTransaction({
                from: owner,
                to: account.address,
                value: amount
            });

            const destBalance = await web3.eth.getBalance(dest);

            await account.execute(OPERATION_CALL, dest, amount, "0x0", {
                from: owner
            });

            const finalBalance = await web3.eth.getBalance(dest);

            assert.isTrue(new BN(destBalance).add(amount).eq(new BN(finalBalance)));
        });

        it("Fails with non-owner executing", async () => {
            const dest = accounts[6];
            const amount = ether("10");
            const OPERATION_CALL = 0x0;

            await web3.eth.sendTransaction({
                from: owner,
                to: account.address,
                value: amount
            });

            await expectRevert(
                account.execute(OPERATION_CALL, dest, amount, "0x0", {
                    from: newOwner
                }),
                "only-owner-allowed"
            );
        });
    }); //Context interactions

    context("Using key manager as Account owner", async () => {
        let manager,
            account = {};
        const owner = accounts[6];

        beforeEach(async () => {
            account = await Account.new({from: owner});
            manager = await KeyManager.new(account.address, {from: owner});
            await account.changeOwner(manager.address, {from: owner});
        });

        it("Account should have owner as manager", async () => {
            const idOwner = await account.owner.call();

            assert.equal(idOwner, manager.address, "Addresses should match");
        });

        it("Key manager can execute on behalf of Idenity", async () => {
            const dest = accounts[1];
            const amount = ether("10");
            const OPERATION_CALL = 0x0;

            //Fund Account contract
            await web3.eth.sendTransaction({
                from: owner,
                to: account.address,
                value: amount
            });

            // Intial Balances
            const destBalance = await web3.eth.getBalance(dest);
            const idBalance = await web3.eth.getBalance(account.address);
            const managerBalance = await web3.eth.getBalance(manager.address);

            await manager.execute(OPERATION_CALL, dest, amount, "0x0", {
                from: owner
            });

            //Final Balances
            const destBalanceFinal = await web3.eth.getBalance(dest);
            const idBalanceFinal = await web3.eth.getBalance(account.address);
            const managerBalanceFinal = await web3.eth.getBalance(manager.address);

            assert.equal(
                managerBalance,
                managerBalanceFinal,
                "manager balance shouldn't have changed"
            );

            assert.isTrue(
                new BN(destBalance).add(amount).eq(new BN(destBalanceFinal)),
                "Destination address should have recived amount"
            );

            assert.isTrue(
                new BN(idBalance).sub(amount).eq(new BN(idBalanceFinal)),
                "Account should have spent amount"
            );
        });
    }); //Context key manager
});
