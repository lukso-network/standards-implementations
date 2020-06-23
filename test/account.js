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
        });``
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
                "Only the owner can call this method"
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
                "Only the owner can call this method"
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

            // send money to the account
            await web3.eth.sendTransaction({
                from: owner,
                to: account.address,
                value: amount
            });

            // try to move it away
            await expectRevert(
                account.execute(OPERATION_CALL, dest, amount, "0x0", {
                    from: newOwner
                }),
                "Only the owner can call this method"
            );
        });

        // TODO test delegateCall

        it("Allows owner to execute create", async () => {
            const dest = accounts[6];
            const amount = ether("10");
            const OPERATION_CREATE = 0x3;

            let receipt = await account.execute(OPERATION_CREATE, dest, '0', "0x608060405234801561001057600080fd5b506040516105f93803806105f98339818101604052602081101561003357600080fd5b810190808051906020019092919050505080600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050610564806100956000396000f3fe60806040526004361061003f5760003560e01c806344c028fe1461004157806354f6127f146100fb578063749ebfb81461014a5780638da5cb5b1461018f575b005b34801561004d57600080fd5b506100f96004803603608081101561006457600080fd5b8101908080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803590602001906401000000008111156100b557600080fd5b8201836020820111156100c757600080fd5b803590602001918460018302840111640100000000831117156100e957600080fd5b90919293919293905050506101e6565b005b34801561010757600080fd5b506101346004803603602081101561011e57600080fd5b81019080803590602001909291905050506103b7565b6040518082815260200191505060405180910390f35b34801561015657600080fd5b5061018d6004803603604081101561016d57600080fd5b8101908080359060200190929190803590602001909291905050506103d3565b005b34801561019b57600080fd5b506101a46104df565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146102a9576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260128152602001807f6f6e6c792d6f776e65722d616c6c6f776564000000000000000000000000000081525060200191505060405180910390fd5b600085141561030757610301848484848080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050610505565b506103b0565b60018514156103aa57600061035f83838080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505061051d565b90508073ffffffffffffffffffffffffffffffffffffffff167fcf78cf0d6f3d8371e1075c69c492ab4ec5d8cf23a1a239b6a51a1d00be7ca31260405160405180910390a2506103af565b600080fd5b5b5050505050565b6000806000838152602001908152602001600020549050919050565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610496576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260128152602001807f6f6e6c792d6f776e65722d616c6c6f776564000000000000000000000000000081525060200191505060405180910390fd5b806000808481526020019081526020016000208190555080827f35553580e4553c909abeb5764e842ce1f93c45f9f614bde2a2ca5f5b7b7dc0fb60405160405180910390a35050565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600080600083516020850186885af190509392505050565b60008151602083016000f0905091905056fea265627a7a723158207fb9c8d804ca4e17aec99dbd7aab0a61583b56ebcbcb7e05589f97043968644364736f6c634300051100320000000000000000000000009501234ef8368466383d698c7fe7bd5ded85b4f6", {
                from: owner
            });

            assert.equal(receipt.logs[0].event, 'ContractCreated');
        });

        it("Allows owner to execute create2", async () => {
            const dest = accounts[6];
            const amount = ether("10");
            const OPERATION_CREATE = 0x2;

            // deploy with added 32 bytes salt
            let receipt = await account.execute(OPERATION_CREATE, dest, '0', "0x608060405234801561001057600080fd5b506040516105f93803806105f98339818101604052602081101561003357600080fd5b810190808051906020019092919050505080600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050610564806100956000396000f3fe60806040526004361061003f5760003560e01c806344c028fe1461004157806354f6127f146100fb578063749ebfb81461014a5780638da5cb5b1461018f575b005b34801561004d57600080fd5b506100f96004803603608081101561006457600080fd5b8101908080359060200190929190803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803590602001906401000000008111156100b557600080fd5b8201836020820111156100c757600080fd5b803590602001918460018302840111640100000000831117156100e957600080fd5b90919293919293905050506101e6565b005b34801561010757600080fd5b506101346004803603602081101561011e57600080fd5b81019080803590602001909291905050506103b7565b6040518082815260200191505060405180910390f35b34801561015657600080fd5b5061018d6004803603604081101561016d57600080fd5b8101908080359060200190929190803590602001909291905050506103d3565b005b34801561019b57600080fd5b506101a46104df565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146102a9576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260128152602001807f6f6e6c792d6f776e65722d616c6c6f776564000000000000000000000000000081525060200191505060405180910390fd5b600085141561030757610301848484848080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050610505565b506103b0565b60018514156103aa57600061035f83838080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505061051d565b90508073ffffffffffffffffffffffffffffffffffffffff167fcf78cf0d6f3d8371e1075c69c492ab4ec5d8cf23a1a239b6a51a1d00be7ca31260405160405180910390a2506103af565b600080fd5b5b5050505050565b6000806000838152602001908152602001600020549050919050565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610496576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260128152602001807f6f6e6c792d6f776e65722d616c6c6f776564000000000000000000000000000081525060200191505060405180910390fd5b806000808481526020019081526020016000208190555080827f35553580e4553c909abeb5764e842ce1f93c45f9f614bde2a2ca5f5b7b7dc0fb60405160405180910390a35050565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600080600083516020850186885af190509392505050565b60008151602083016000f0905091905056fea265627a7a723158207fb9c8d804ca4e17aec99dbd7aab0a61583b56ebcbcb7e05589f97043968644364736f6c634300051100320000000000000000000000009501234ef8368466383d698c7fe7bd5ded85b4f6"
                // 32 bytes salt
                + "cafecafecafecafecafecafecafecafecafecafecafecafecafecafecafecafe", {
                from: owner
            });

            // console.log(receipt.logs[0].args);

            assert.equal(receipt.logs[0].event, 'ContractCreated');
            assert.equal(receipt.logs[0].args.contractAddress, '0x7ffE4e82BD27654D31f392215b6b145655efe659');
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
