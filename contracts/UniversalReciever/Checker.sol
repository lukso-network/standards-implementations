pragma solidity 0.5.10;

import "./UniversalReciever.sol";

contract Checker {
    function checkImplementation(address target, bytes32 inter) external returns (bool) {
        bytes32 ret = UniversalReciever(target).universalReciever(inter, "");
        return ret == inter;
    }

}