pragma solidity 0.5.10;

import "./UniversalReciever.sol";

contract Caller {

    event Trace(bytes da);
    function callReciever(address _to) external {
        UniversalReciever ur = UniversalReciever(_to);
        bytes memory data = abi.encodePacked(address(msg.sender), address(_to), uint(100));
        bytes32 hash = keccak256("tokenRecieve");
        emit Trace(data);
        ur.recieve(hash, data);
    }
}