// SPDX-License-Identifier: MIT

/*
    Safenakamoto Deflationary token is a deflationary token based on burning.
    
    In each transaction 1% of the tokens are redirected to a multisig wallet of the Safenakamoto team. 
    They will evaluate which are the most propitious time to burn tokens trying to avoid dumps and promoting the price increase. 
    Once SNK's total supply has been reduced to 15 million the NFT store will open.

    
    Site: https://www.safenakamoto.com
    Twitter: https://www.twitter.com/safenakamoto
    Telegram: https://t.me/safenakamoto
    
    For more: Read litepaper on Safenakamoto site. 

*/

pragma solidity ^0.6.2;

import "./openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Safanakamoto is ERC20 {

    uint256 private _minimumSupply = 2000 * (10 ** 18);
    address _burnPoolAddress = 0xE0bBcE75D95653d9392c34B16941fd29F27F024B;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20( "SafeNakamoto", "SNK") {
        _mint(msg.sender, 21000000 * (10 ** uint256(decimals())));
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        return super.transfer(to, _partialBurn(amount));
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        return super.transferFrom(from, to, _partialBurn(amount));
    }

    function _partialBurn(uint256 amount) internal returns (uint256) {
        uint256 burnAmount = _calculateBurnAmount(amount);

        if (burnAmount > 0) {
            _sendFeeToBurn(burnAmount);
        }
    
        return amount.sub(burnAmount);
    }
    
    function _sendFeeToBurn(uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), _burnPoolAddress, amount);
        return true;
    }

    function _calculateBurnAmount(uint256 amount) internal view returns (uint256) {
        uint256 burnAmount = 1;

        // burn amount calculations
        if (totalSupply() > _minimumSupply) {
            burnAmount = amount.div(100);
            uint256 availableBurn = totalSupply().sub(_minimumSupply);
            if (burnAmount > availableBurn) {
                burnAmount = availableBurn;
            }
        }

        return burnAmount;
    }   
}
