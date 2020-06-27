// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.7.0;

interface IERC725base {
    event OwnerChanged(address indexed ownerAddress);

    function owner() external view returns (address);
    function changeOwner(address newOwner) external;
}
