pragma solidity 0.5.10;

import "../_ERCs/IERC725.sol";
import "../Tokens/ERC777-UniversalReceiver.sol";

contract DigitalCertificate is IERC725, ERC777 {

    mapping(bytes32 => bytes) store;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == address(owner), "only-owner-allowed");
        _;
    }


    // certificate should not be able to receive ETH/LYX
    function() external {}

    function changeOwner(address _newOwner)
    public
    onlyOwner
    {
        owner = _newOwner;
        emit OwnerChanged(owner);
    }

    function getData(bytes32 _key)
    public
    view
    returns (bytes memory _value)
    {
        return store[_key];
    }

    function setData(bytes32 _key, bytes memory _value)
    public
    onlyOwner
    {
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data) external {
        // TODO add execute?
    }

}