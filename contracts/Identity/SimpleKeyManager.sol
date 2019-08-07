pragma solidity 0.5.10;

import "./Identity.sol";

contract SimpleKeyManager {

    address public owner;
    Identity public identity;

    event Execution(uint256 _operationType, address _to, uint256 _value, bytes _data);
    constructor(address payable _identity) public {
        owner = msg.sender;
        identity = Identity(_identity);
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "only-owner-allowed");
        _;
    }

    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data) onlyOwner external {
        identity.execute(_operationType, _to, _value, _data);
        emit Execution(_operationType, _to, _value, _data);
    }

}