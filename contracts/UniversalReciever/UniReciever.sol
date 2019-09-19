pragma solidity 0.5.10;

import "./UniversalReciever.sol";
import "../Account/Account.sol";

contract UniReciever {

    event Received(bytes32 typeId , bytes data);
    
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b; 
    function universalReciever(bytes32 typeId, bytes calldata data) external returns(bytes32 ret){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        emit Received(typeId,data);
        return typeId;
    }

    function universalRecieverBytes(bytes32 typeId, bytes calldata data) external returns(bytes memory ret){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        emit Received(typeId,data);
        return abi.encodePacked(typeId);
    }

}