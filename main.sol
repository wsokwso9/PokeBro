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
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => address) private _getApproved;
    mapping(address => mapping(address => bool)) private _isApprovedForAll;

    constructor() {
        owner = msg.sender;
        minter = msg.sender;
        deployBlock = block.number;
        genesisHash = keccak256(abi.encodePacked("PokeBro", block.chainid, block.prevrandao, PBRO_CHAIN_SALT));
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert PBRO_NotOwner();
        _;
    }

    modifier onlyMinter() {
        if (msg.sender != minter) revert PBRO_NotMinter();
        _;
    }

    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) revert PBRO_ZeroAddress();
        address prev = minter;
        minter = newMinter;
        emit MinterSet(prev, newMinter, block.number);
    }

    function mint(address to, uint256 tokenId) external onlyMinter {
        if (to == address(0)) revert PBRO_ZeroAddress();
        if (tokenId >= PBRO_MAX_SUPPLY) revert PBRO_ExceedsMaxSupply();
        if (_ownerOf[tokenId] != address(0)) revert PBRO_AlreadyMinted();
        _ownerOf[tokenId] = to;
        _balanceOf[to]++;
        _mintedCount++;
        emit Transfer(address(0), to, tokenId);
        emit Minted(to, tokenId, block.number);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address o = _ownerOf[tokenId];
        if (o == address(0)) revert PBRO_InvalidTokenId();
        return o;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (account == address(0)) revert PBRO_ZeroAddress();
        return _balanceOf[account];
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        if (_ownerOf[tokenId] == address(0)) revert PBRO_InvalidTokenId();
        return _getApproved[tokenId];
    }

    function isApprovedForAll(address account, address operator) external view returns (bool) {
        return _isApprovedForAll[account][operator];
    }

    function approve(address approved, uint256 tokenId) external {
        address o = _ownerOf[tokenId];
        if (o == address(0)) revert PBRO_InvalidTokenId();
        if (o != msg.sender && !_isApprovedForAll[o][msg.sender]) revert PBRO_NotOwnerNorApproved();
        _getApproved[tokenId] = approved;
        emit Approval(o, approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        if (operator == address(0)) revert PBRO_ZeroAddress();
        _isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        if (to == address(0)) revert PBRO_ZeroAddress();
        address o = _ownerOf[tokenId];
        if (o == address(0)) revert PBRO_InvalidTokenId();
        if (from != o) revert PBRO_NotOwnerNorApproved();
        if (msg.sender != from && msg.sender != _getApproved[tokenId] && !_isApprovedForAll[from][msg.sender]) revert PBRO_NotOwnerNorApproved();
        _ownerOf[tokenId] = to;
        _balanceOf[from]--;
        _balanceOf[to]++;
        _getApproved[tokenId] = address(0);
        emit Transfer(from, to, tokenId);
