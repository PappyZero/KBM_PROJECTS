// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/access/Ownable.sol"; 
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFT is ERC721URIStorage, Ownable

{
    using Strings for uint256;

    uint256 public constant MAX_TOKENS = 10000;

    uint256 private constant TOKENS_RESERVED = 5; 

    uint256 public price = 80000000000000000;

    uint256 public constant MAX_MINT_PER_TX = 10;

    bool public is_sale_active;

    uint256 public total_supply;

    mapping (address => uint256) private minted_per_wall;

    string public base_uri;
    string public base_ext = ".json";


    constructor() ERC721("PAPPYZERO PAPPY", "PPY") Ownable(msg.sender)    {
        base_uri = "ipfs://xxxxxxxxxxxxxxxxxxxxxxxxxxxxx/";

        for (uint256 i = 1; i <= TOKENS_RESERVED; ++i)
        {
            _safeMint(msg.sender, i);
        } 

        total_supply = TOKENS_RESERVED;
    }

    function mint(uint256 _num_tokens) external payable 
    {
        require(is_sale_active, "The sale is currently paused!!");

        require(_num_tokens <= MAX_MINT_PER_TX, "Only a maximum of 10 NFTs per Transactions can be minted!!!");

        require(minted_per_wall[msg.sender] + _num_tokens <= 10, "Only 10 can be minted per wallet.");

        uint256 cur_total_supply = total_supply;

        require(cur_total_supply + _num_tokens <= MAX_TOKENS, "You have Exceeded the Maximum Supply of NFT Collection");

        require(_num_tokens * price <= msg.value, "ETH Balance is Insufficient!!!");

        for (uint256 i = 1; i <= _num_tokens; ++i)
        {
            _safeMint(msg.sender, cur_total_supply + i);
        }


        minted_per_wall[msg.sender] += _num_tokens;

        total_supply += _num_tokens;
    }

    function flip_sale_state() external onlyOwner
    {

        is_sale_active = !is_sale_active;
    }

    function set_base_uri(string memory _base_uri) external onlyOwner
    {
        base_uri = _base_uri;
    }

    function set_price(uint256 _price) external onlyOwner
    {
        price = _price;
    }

    function withdraw_all() external payable onlyOwner
    {
        uint256 bal = address(this).balance;

        uint256 bal_one = bal * 50 / 100;
        uint256 bal_two = bal * 50 / 100;

        (bool transfer_one,) = payable (0x3588A759E06FFeFFfc7b0b8cb3aB061997401328).call{value: bal_one}("");
        (bool transfer_two,) = payable (0x3588A759E06FFeFFfc7b0b8cb3aB061997401328).call{value: bal_two}("");
        require(transfer_one && transfer_two, "The Transfer Failed!!!");
    }

    // Declaring a function to handle the "base_uri".
    // function token_uri(uint256 token_id) public  view virtual override returns (string memory)
    // {
    //     require(_exists(token_id), "ERC721Metadata: URI query for nonexistent token");
    //     string memory current_base_uri = _base_uri();
    //     return bytes(current_base_uri).length > 0
    //         ? string(abi.encodePacked(current_base_uri, token_id.toString(), baseExtension))
    //         : "";
        
    // }

    // // Internal Functions
    // function _base_uri() internal view virtual override returns (string memory)
    // { 
    //     return base_uri;
    // }



}