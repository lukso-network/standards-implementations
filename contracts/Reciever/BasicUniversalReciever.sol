pragma solidity 0.5.10;

import "./UniversalReciever.sol";
import "../Identity/Identity.sol";

contract BasicUniversalReciever is Identity, UniversalReciever {

    event TokenRecieved(address from, address to, uint256 amount);

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            //tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
            tempAddress := mload(add(add(_bytes, 0x14), _start))
        }

        return tempAddress;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
    event Debug(address add);
    function recieve(bytes32 typeId, bytes calldata data) external {
        address to = toAddress(data, 0);
        address from = toAddress(data, 20);
        uint amount = toUint(data, 40);
        emit Debug(to);
        emit Debug(from);
        emit TokenRecieved(to, from, amount);
        emit Received(typeId,data);
    }

}