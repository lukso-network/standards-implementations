// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.6.10;

import "../_LSPs/ILSP1_UniversalReceiver.sol";

contract UniversalReceiverExample is ILSP1 {

    event TokenReceived(address tokenContract, address from, address to, uint256 amount);
    bytes32 constant internal TOKEN_RECEIVE = keccak256("TOKEN_RECEIVE");

    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72, "data has wrong size");
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function universalReceiver(bytes32 typeId, bytes calldata data)
    external
    override
    returns (bytes32)
    {
        if(typeId == TOKEN_RECEIVE){
            (address from, address to, uint256 amount) = toTokenData(data);
            emit TokenReceived(msg.sender, from, to, amount);
        }

        emit UniversalReceiver(msg.sender, typeId, 0x0, data);

        return 0x0;
    }
}
