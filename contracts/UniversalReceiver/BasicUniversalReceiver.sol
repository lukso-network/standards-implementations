pragma solidity ^0.6.0;

import "../_LSPs/ILSP1_UniversalReceiver.sol";
import "../Account/Account.sol";

contract BasicUniversalReceiver is Account {

    event TokenReceived(address token, address from, address to, uint256 amount);

    function toTokenData(bytes memory _bytes) internal pure returns (address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72, "data has wrong size");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32) {
        (address from, address to,uint amount) = toTokenData(data);
        emit TokenReceived(msg.sender, from, to, amount);
        emit Received(typeId, data);
    }

}
