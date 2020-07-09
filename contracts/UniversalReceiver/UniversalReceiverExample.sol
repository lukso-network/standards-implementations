// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "../_LSPs/ILSP1_UniversalReceiver.sol";

contract UniversalReceiverExample {

    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
    0x3d74c01657c02cd6933da4fcd70aadab403f3b222e30c05b3536cb11fb083e15; // keccak256("LSP1_ERC777TokensSender")

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
    0x2352f13a810c120f366f70972476f743e16a9f2196b4b60037b84185ecde66d3; // keccak256("LSP1_ERC777TokensRecipient")

    event Received(bytes32 indexed typeId, bytes data);

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32 ret){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH || typeId == _TOKENS_SENDER_INTERFACE_HASH);
        emit Received(typeId, data);
        return typeId;
    }
}
