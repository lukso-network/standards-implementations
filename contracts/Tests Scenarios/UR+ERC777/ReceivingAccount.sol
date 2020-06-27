// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "./ERC777Receiver.sol";
import "../../_LSPs/ILSP1_UniversalReceiver.sol";
import "../../../node_modules/@openzeppelin/contracts/introspection/ERC1820Implementer.sol";
import "../../Account/Account.sol";

contract ReceivingAccount is Account, ERC1820Implementer {
    
    ERC777Receiver public receiver;


    constructor(address _owner) Account(_owner) public {
    }

    function changeReceiver(address _newReceiver) onlyOwner external {
        receiver = ERC777Receiver(_newReceiver);
    }

    function universalReceiver(bytes32 typeId ,bytes memory data) override external returns(bytes32 ret){
        ret = receiver.universalReceiver(_msgSender(), typeId,data);
        emit Received(typeId,data);
    }

}
