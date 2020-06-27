// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;
import "./_ERCs/IERC725X.sol";
import "./_ERCs/IERC725Y.sol";
import "./_ERCs/IERC1271.sol";
import "./_LSPs/ILSP1_UniversalReceiver.sol";


contract CalculateERC165Selectors {

    function calculateSelectorLSP1() public pure returns (bytes4) {
        ILSP1 i;

        return i.universalReceiver.selector;
    }

    function calculateSelectorERC725X() public pure returns (bytes4) {
        IERC725X i;

        return i.owner.selector
        ^ i.changeOwner.selector
        ^ i.execute.selector;
    }

    function calculateSelectorERC725Y() public pure returns (bytes4) {
        IERC725Y i;

        return i.owner.selector
        ^ i.changeOwner.selector
        ^ i.getData.selector
        ^ i.setData.selector;
    }

    function calculateSelectorERC1271() public pure returns (bytes4) {
        IERC1271 i;

        return i.isValidSignature.selector;
    }
}
