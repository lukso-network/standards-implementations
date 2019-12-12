pragma solidity 0.5.10;

import "../_ERCS/IERC725.sol";
import "../Tokens/ERC721-UniversalReceiver.sol";

contract DigitalCertificate is IERC725, ERC721 {

    mapping(bytes32 => bytes) store;

    address public owner;

    // TODO add inital authentic data
    constructor() public {
        owner = msg.sender;
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

    // TODO add execute?

    // TODO add  721
    function mint(address _to, uint256 _tokenId)
    public
    onlyOwner
    {
        _safeMint(_to, _tokenId);
    }

    function mintBatch(address[] memory _to, uint256[] memory _tokenId)
    public
    onlyOwner
    {
        for (uint16 i = 0; i < _to.length; i++) {
            _safeMint(_to[i], _tokenId[i]);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only-owner-allowed");
        _;
    }
}