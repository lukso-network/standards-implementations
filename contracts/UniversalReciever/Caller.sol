pragma solidity 0.5.10;

import "./BareReciever/BasicUniversalReciever.sol";
import "./TypedReciever/TypedReciever.sol";

contract Caller {

    event Trace(bytes da);
    function callBareTokenReciever(address payable _to) external {
        BasicUniversalReciever ur = BasicUniversalReciever(_to);
        bytes memory data = abi.encodePacked(address(msg.sender), address(_to), uint(100 ether));
        bytes32 hash = keccak256(abi.encodePacked("Token"));
        emit Trace(data);
        ur.recieve(hash, data);
    }

    // function callTypedTokenReciever(address _to) external {
    //     TypedReciever tr = TypedReciever(_to);
    //     bytes memory data = abi.encodePacked(address(msg.sender), address(_to), uint(100));
    //     bytes32 hash = keccak256(abi.encodePacked(uint(1)));
    //     emit Trace(data);
    //     tr.recieve(hash, data);
    // }
}