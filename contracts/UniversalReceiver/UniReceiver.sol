pragma solidity 0.5.10;

import "../_LSPs/LSP1_UniversalReceiver.sol";
import "../Account/Account.sol";

contract UniReceiver {

    event Received(bytes32 typeId, bytes data);

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32 ret){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        emit Received(typeId, data);
        return typeId;
    }

    function universalReceiverBytes(bytes32 typeId, bytes calldata data) external returns (bytes memory ret){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        emit Received(typeId, data);
        return abi.encodePacked(typeId);
    }

}