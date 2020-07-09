// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;


contract ExternalERC777UniversalReceiverTester {

    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
    0x3d74c01657c02cd6933da4fcd70aadab403f3b222e30c05b3536cb11fb083e15; // keccak256("LSP1_ERC777TokensSender")

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
    0x2352f13a810c120f366f70972476f743e16a9f2196b4b60037b84185ecde66d3; // keccak256("LSP1_ERC777TokensRecipient")


    event ReceivedERC777(address indexed token, address indexed _operator, address indexed _from, address _to, uint256 _amount);

    function universalReceiverDelegate(address sender, bytes32 typeId, bytes memory data) external returns(bytes32){

        if(typeId == TOKENS_RECIPIENT_INTERFACE_HASH) {
            (address _operator, address _from, address _to, uint256 _amount) = toERC777Data(data);

            emit ReceivedERC777(sender, _operator, _from, _to, _amount);

            return "";

        } else if(typeId == _TOKENS_SENDER_INTERFACE_HASH) {

            return "";

        } else {
            revert("UniversalReceiverDelegate: Given typeId not supported.");
        }
    }


    function toERC777Data(bytes memory _bytes) internal pure returns(address _operator, address _from, address _to, uint256 _amount) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _operator := mload(add(add(_bytes, 0x14), 0x0))
            _from := mload(add(add(_bytes, 0x14), 0x14))
            _to := mload(add(add(_bytes, 0x28), 0x28))
            _amount := mload(add(add(_bytes, 0x20), 0x42))

        }
    }
}
