pragma solidity 0.5.10;

import "./BareReciever.sol";
import "../../Account/Account.sol";

contract BasicBareReciever is Account, BareReciever {

    event TokenRecieved(address from, address to, uint256 amount);

    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function recieve(bytes32 typeId, bytes calldata data) external {
        (address from, address to,uint amount) = toTokenData(data);
        emit TokenRecieved(from,to, amount);
        emit Received(typeId,data);
    }

}