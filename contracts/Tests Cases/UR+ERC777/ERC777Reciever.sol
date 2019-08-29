pragma solidity 0.5.10;

import "../../UniversalReciever/UniversalReciever.sol";
import "../../Account/Account.sol";


contract ERC777Reciever is UniversalReciever{

    event RecievedERC777(address _operator, address _from, address _to, uint256 _amount);

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    function toERC777Data(bytes memory _bytes) internal pure returns(address _operator, address _from, address _to, uint256 _amount) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _operator := mload(add(add(_bytes, 0x14), 0x0))
            _from := mload(add(add(_bytes, 0x14), 0x14))
            _to := mload(add(add(_bytes, 0x28), 0x28))
            _amount := mload(add(add(_bytes, 0x20), 0x42))

        }
    }

    function recieve(address sender,bytes32 typeId,bytes calldata data) external{
        require(typeId == TOKENS_RECIPIENT_INTERFACE_HASH);
        (address _operator, address _from, address _to, uint256 _amount) = toERC777Data(data);
        emit RecievedERC777(_operator, _from, _to, _amount);
    }
}