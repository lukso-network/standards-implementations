pragma solidity 0.5.10;

import "../TypedReciever/TypedReciever.sol";
import "../../Account/SimpleKeyManager.sol";

/// @title RecieveAndRedirect
/// @author @JGCarv
/// @notice Contract used for recieving and imediataley redirecting tokens
contract RecieveAndRedirect is TypedReciever{

    address public coldWallet;
    SimpleKeyManager public keyManager;

    event RecievedCustom(address self, address msgSender, address from, uint256 amount, bytes data);
    event SentToWallet(address wallet, uint amount);

    constructor(address _keyManager, address _coldwallet) public {
        keyManager = SimpleKeyManager(_keyManager);
        coldWallet = _coldwallet;
    }

    // function toAddress(bytes memory _bytes) pure internal returns(address _add){

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         _add := mload(add(add(_bytes, 0x14), 0x0))
    //     }
    // }

    function sendToColdWallet(address token, address recipient, uint256 amount) internal {
        //Calling the keyManager can also become confusing. Here we need to pass the Operation_code as a first parameter,
        // the destination contract as a second parameter, the ETH(not Token!) amount in the call and finally the enconded
        //data for executing a transfer function
        bytes memory data = abi.encodeWithSelector(0xa9059cbb, recipient, amount);
        keyManager.execute(0,token,0, data);
        emit SentToWallet(recipient,amount);
    }
    
    function recieve(address sender, bytes32 typeId, address from, address to, uint256 amount, bytes calldata data) external {
        sendToColdWallet(sender, coldWallet,amount);
        emit RecievedCustom(address(this),msg.sender,from,amount,data);
    }

}