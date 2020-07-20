// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "erc725/contracts/ERC725/ERC725Y.sol";
import "../Tokens/ERC777-UniversalReceiver.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";


abstract contract DigitalCertificate is Pausable, ERC725Y, ERC777UniversalReceiver {

    bytes32[] public dataKeys;
    address public minter;


    constructor(
        address newOwner,
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    )
    ERC725Y(newOwner)
    ERC777UniversalReceiver(name, symbol, defaultOperators)
    public {
        // set owner as default operator
        // allows to recover funds and mint
        _defaultOperatorsArray.push(newOwner);
        _defaultOperators[newOwner] = true;

        // set the owner as minter
        minter = newOwner;
    }

    /* non-standard public functions */

    function mint(uint256 _amount)
    external
    override
    onlyMinter
    {
        _mint(_msgSender(), _amount, "", "");
    }

    function removeMinter()
    external
    onlyMinter
    {
        minter = address(0);
    }

    // Stops account recovery possibility
    function removeDefaultOperators()
    external
    {
        require(_defaultOperators[_msgSender()], 'Only default operators can call this function');
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = false;
        }
        delete _defaultOperatorsArray;
    }

    function pause()
    internal
    whenNotPaused
    {
        require(_defaultOperators[_msgSender()], 'Only default operators can call this function');
        _pause();
    }

    function unpause()
    internal
    whenPaused
    {
        require(_defaultOperators[_msgSender()], 'Only default operators can call this function');
        _unpause();
    }

    function dataCount() public view returns (uint256) {
        return dataKeys.length;
    }

    function allDataKeys() public view returns (bytes32[] memory) {
        return dataKeys;
    }


    /* Public functions */

    function setData(bytes32 _key, bytes memory _value)
    external
    override
    onlyOwner
    {
        if(store[_key].length == 0) {
            dataKeys.push(_key); // 30k more gas on initial set
        }
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }


    /* Internal functions */
    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal
    override
    whenNotPaused
    {
        ERC777UniversalReceiver._move(operator, from, to, amount, userData, operatorData);
    }


    /* Modifers */
    modifier onlyMinter() {
        require(_msgSender() == minter, 'Only minter can call this function');
        _;
    }
}
