# Universal Recievers (WIP)

This folder contains research relating to universal recievers, a mechanism to notify contracts of incoming transactions.


### Bare Reciever
```solidity
interface BareReciever {
    event Received(address sender, bytes32 typeId , bytes data);
    function recieve(address sender bytes32 typeId ,bytes calldata data) external;
}
```
The bare reciever accepts only a typeId, which determines the type of the recieving(token,NFT,etc) and a byte array with the information. In the bare reciever, the implementing contract takes care of decoding parameters, which can only be done efficiently using inline assembly.

### Typed Reciever
```solidity
interface TypedReciever {
    event Recieved(address sender,bytes32 typeId , address from, address to, uint256 amount, bytes data);
    function recieve(address sender,bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external;
}
```  
In the typed reciver, some basic parameter are already baked into the standard and the implementing contract doesn't need to do much work.

#### Benchmarking gas consumption

Two very basic contracts were defined: `BasicBareReciever.sol` and `BasicTypedReciever.sol`. Each one recieves a function and emits an event `TokenRecieved(address from, address to, uint256 amount)`

Gas consumed:
`BasicBareReciever.sol`: `30441`

`BasicTypedReciever.sol`: `30892`

#### Other notes on Bare vs Typed
* The bare reciever will require a diferent parsing function for each type, which may lead to quite large and complex recieving contracts
* The typed can end up limiting the usability of the reciever due to the constraints.    


## Implementing a Reciever

Recivers can be called in two maim ways: with a external or with a delegate call. The ups and downs of each approach is discussed in this section:  

#### Benchmarking gas consumption
External call gas usage:  34525
Delegate call gas usage:  34770

### External Reciever
* Making transaction to reciever makes the call loose the reference for the token address
* It requires pre-authorization with the account key manager to allow for actionable recieves 

### Delegate Reciever
* It can act on the behalf of the account itself

## Implementing a more complex scenario
In here, we define a possible scenario of transfering a token, where the recivieving contracts gets notified and redirects the recieved token for a third address. For this we're using the `Bare Reciever` and using a modified ERC20 token.

There're three possible implementations

1. Bare Reciever + external call + key manager
The account makes a external call to the reciever, which makes another external call to the key manager which executes a token trasnfer on behalf of account.
This whole operations costs around `76739` gas.

2. Bare Reciever + delegate call + key manager
The account makes a delegate call to the reciever, which makes another external call to the key manager which executes a token trasnfer on behalf of account.
This whole operations costs around `78406` gas. 

3. Bare Reciever + delegate call + self redirecting
The account makes a delegate call to the reciever, which makes another external call to the token.
This whole operations costs around `68134` gas.

* On cases `2` and  `3` the reciever has to inherit from the account contract, so the delegate call is possible without messing with the storage layout. This makes upgradability a bit more error-prone.
* On cases `1`and `2` the recievers must be pre-authorized in the key manager, with the ability to execute automatically. Some more complex logic can be added, for example, allowing automatic transfer only if the amount is less than `x value`  
* `3` bypasses the key manager because it assumes that the account can act on behalf of itself. 

