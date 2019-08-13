pragma solidity 0.5.10;

import "./BareReciever.sol";
import "../../Account/Account.sol";

contract BasicUniversalReciever is Account, BareReciever {

    event TokenRecieved(address from, address to, uint256 amount);

    mapping(bytes32 => bool) public acceptedTypes;

    constructor(bytes32[] memory _acceptedTypes) public {
        for(uint i = 0; i < _acceptedTypes.length; i++){
            acceptedTypes[_acceptedTypes[i]] = true;
        }
    }

    function toTokenData(bytes memory _bytes) internal pure returns(address _to, address _from, uint256 _amount) {
        require(_bytes.length == 72);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _to := mload(add(add(_bytes, 0x14), 0x0))
            _from := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function recieve(bytes32 typeId, bytes calldata data) external {
        if(acceptedTypes[typeId]){
            (address to, address from,uint amount) = toTokenData(data);
            emit TokenRecieved(to, from, amount);
            emit Received(typeId,data);
        } else {
            revert();
        }
    }

}