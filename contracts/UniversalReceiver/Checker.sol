pragma solidity 0.5.10;

import "./UniReceiver.sol";

contract Checker {
    function checkImplementation(address target, bytes32 inter) external returns (bool) {
        bytes32 ret = UniReceiver(target).universalReceiver(inter, "");
        return ret == inter;
    }

    function checkImplementationBytes(address target, bytes32 inter) external returns (bool) {
        bytes memory ret = UniReceiver(target).universalReceiverBytes(inter, "");
        return equal(ret, abi.encodePacked(inter));
    }

    function lowLevelCheckImplementation(address target, bytes32 inter) external returns (bool) {
        (bool succ, bytes memory ret) = target.call(abi.encodeWithSignature("universalReceiver(bytes32,bytes)", inter, ""));
        bytes32 response = toBytes32(ret, 0);
        return succ && response == inter;
    }

    function lowLevelCheckImplementationBytes(address target, bytes32 inter) external returns (bool) {
        (bool succ, bytes memory ret) = target.call(abi.encodeWithSignature("universalReceiverBytes(bytes32,bytes)", inter, ""));
        return succ && equal(ret, abi.encodePacked(inter));
    }

    function toBytes32(bytes memory _bytes, uint _start) internal pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }


    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

        // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
            // cb is a circuit breaker in the for loop since there's
            //  no said feature for inline assembly loops
            // cb = 1 - don't breaker
            // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                    // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
            // unsuccess:
                success := 0
            }
        }

        return success;
    }

}