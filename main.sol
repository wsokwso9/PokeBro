// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * Zephyr batch #12 — PokeBro NFT: fixed-cap collectible run, intended for cross-promo with PokeMenu launchpad.
 * @dev Minter is set at deploy (e.g. PokeMenu). Max supply 100000. ERC721-compatible mint and balance.
 */

interface IPokeBroMint {
    function mint(address to, uint256 tokenId) external;
}

contract PokeBro {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event MinterSet(address indexed previous, address indexed current, uint256 atBlock);
    event Minted(address indexed to, uint256 indexed tokenId, uint256 atBlock);

    error PBRO_ZeroAddress();
