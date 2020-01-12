pragma solidity 0.5.10;

import "https://github.com/lukso-network/standards-scenarios/blob/digital-certificates/contracts/DigitialCertificate/DigitalCertificate-fungible.sol";
//import "../../DigitialCertificate/DigitalCertificate-fungible.sol";


contract DCGen1 is DigitalCertificate {

    mapping(bytes32 => bool) private _claimables;

    constructor(string memory name, string memory symbol, address[] memory defaultOperators) ERC777(name, symbol, defaultOperators) public {
        DigitalCertificate.owner = msg.sender;
    }

    // certificate should not be able to receive ETH/LYX
    function() external {}

    /**
    * @dev Claims an item based on the itemId and certificateCode, which is hashed and compared to the stored hash
    */
    function claim(bytes32 _itemId, bytes4 _certificateCode) public {

        bytes memory itemId = 0xF5D18CEF; // DigitalCertificate.getData(0x1234567890);

        if(keccak256(itemId) == _itemId) {
            bytes32 hashed = keccak256(_itemId, _certificateCode);

            if(_claimables[hashed]) {
                address account = msg.sender;

                ERC777._totalSupply = ERC777._totalSupply.add(1000000000000000000);
                ERC777._balances[account] = ERC777._balances[account].add(1000000000000000000);

                ERC777._callTokensReceived(address(0), address(0), account, 1000000000000000000, "", "", false); // Allow transfer to any address

                emit Minted(account, account, 1000000000000000000, "", "");
                emit Transfer(address(0), account, 1000000000000000000);
            }
        }
    }

/**
 * @dev Creates `amount` tokens and assigns them to `account`, increasing
 * the total supply.
 *
 *
 * See `IERC777Sender` and `IERC777Recipient`.
 *
 * Emits `Minted` and `Transfer` events.
 *
 * Requirements
 *
 * - `account` cannot be the zero address.
 * - if `account` is a contract, it must implement the `tokensReceived`
 * interface.
 */
    function mint(
        address account,
        uint256 amount
    )
    public
    onlyOwner
    {
        require(account != address(0), "ERC777: mint to the zero address");

        // Update state variables
        ERC777._totalSupply = ERC777._totalSupply.add(amount);
        ERC777._balances[account] = ERC777._balances[account].add(amount);

        ERC777._callTokensReceived(address(0), address(0), account, amount, "", "", false); // Allow transfer to any address

        emit Minted(account, account, amount, "", "");
        emit Transfer(address(0), account, amount);
    }

}