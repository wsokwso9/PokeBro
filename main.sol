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
    error PBRO_NotMinter();
    error PBRO_ExceedsMaxSupply();
    error PBRO_AlreadyMinted();
    error PBRO_NotOwner();
    error PBRO_InvalidTokenId();
    error PBRO_NotOwnerNorApproved();

    uint256 public constant PBRO_MAX_SUPPLY = 100000;
    bytes32 public constant PBRO_DOMAIN = keccak256("PokeBro.NFT.v1");
    uint256 public constant PBRO_CHAIN_SALT = 0x8D2f4A6c8E0b2D4f6A8c0E2b4D6f8A0c2E4b6D8;

    string public constant name = "PokeBro NFT";
    string public constant symbol = "PBRO";

    address public immutable owner;
    address public minter;
    uint256 public immutable deployBlock;
    bytes32 public immutable genesisHash;

    uint256 private _mintedCount;
    mapping(uint256 => address) private _ownerOf;
