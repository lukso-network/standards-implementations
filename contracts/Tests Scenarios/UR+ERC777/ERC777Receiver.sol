// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "../../_LSPs/ILSP1_UniversalReceiver.sol";
import "../../Account/Account.sol";


contract ERC777Receiver{

    event ReceivedERC777(address token, address _operator, address _from, address _to, uint256 _amount);

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
    0x02f4a83ca167ac46c541f87934d1b98de70d2b06ad0aaefae65c5fdda87ae405; // keccak256("LSP1ERC777TokensRecipient")

    function toERC777Data(bytes memory _bytes) internal pure returns(address _operator, address _from, address _to, uint256 _amount) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _operator := mload(add(add(_bytes, 0x14), 0x0))
            _from := mload(add(add(_bytes, 0x14), 0x14))
            _to := mload(add(add(_bytes, 0x28), 0x28))
            _amount := mload(add(add(_bytes, 0x20), 0x42))

        }
    }

    function universalReceiver(address sender, bytes32 typeId,bytes calldata data) external returns(bytes32){
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        (address _operator, address _from, address _to, uint256 _amount) = toERC777Data(data);
        emit ReceivedERC777(sender, _operator, _from, _to, _amount);
        return typeId;
    }
}
