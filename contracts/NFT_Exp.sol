// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// Imports from online scripts that contains frameworks for writing smart contracts. 
import "@openzeppelin/contracts/access/Ownable.sol"; //This controls who has access to the smart contract. 
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


// Declaring the contract "NFT" as an ERC721 token and ownable.
contract NFT is ERC721URIStorage, Ownable
// contract NFT is ERC721, Ownable, ERC721URIStorage 
// Modified here

{
    using Strings for uint256;

    // Declaring the maximum supply of NFT collection is "10000".
    uint256 public constant MAX_TOKENS = 10000;

    // After deploying the smart contract, 5 tokens will be minted to the wallet. 
    uint256 private constant TOKENS_RESERVED = 5; 

    // Declaring the price in wei (i.e. 0.08eth).
    uint256 public price = 80000000000000000;

    // Declaring the maximum mint per transaction as 10.
    uint256 public constant MAX_MINT_PER_TX = 10;

    // Declaring a boolean variable to check if an active sale is currently going on. 
    bool public is_sale_active;

    uint256 public total_supply;

    // Recording how many NFTs each wallet has minted. 
    mapping (address => uint256) private minted_per_wall;

    string public base_uri;
    string public base_ext = ".json";

    // Defining a Contructor that runs when the contract is deployed. 
    // The Constructor create the ERC721 Token with a "Name" and a "Symbol"
    constructor() ERC721("PAPPYZERO PAPPY", "PPY") Ownable(msg.sender)    {
        // Setting the Base URI of the NFT, which will be an "IPFS Link". 
        base_uri = "ipfs://xxxxxxxxxxxxxxxxxxxxxxxxxxxxx/";

        // Looping through and minting the tokens of the owner that are reserved.
        for (uint256 i = 1; i <= TOKENS_RESERVED; ++i)
        {
            _safeMint(msg.sender, i);
        } 

        // Seeting the "totals_supply" to equals the "tokens_reserved". 
        total_supply = TOKENS_RESERVED;
    }

    // Creating a function thar takes in a number of tokens that will be minted. 
    function mint(uint256 _num_tokens) external payable 
    {
        // A require condition that checks if the sale is currently active. 
        require(is_sale_active, "The sale is currently paused!!");

        // A require condition that checks if the number of tokens minting is
        // less than the max number of tokens oer transaction. 
        require(_num_tokens <= MAX_MINT_PER_TX, "Only a maximum of 10 NFTs per Transactions can be minted!!!");

        // A require condition that checks the address of the caller of the transaction.
        require(minted_per_wall[msg.sender] + _num_tokens <= 10, "Only 10 can be minted per wallet.");

        // Creating a variable "cur_total_supply" and assigning it the "total_supply".
        uint256 cur_total_supply = total_supply;

        // A require condition that checks that the "MAX_TOKENS" has not been exceeded. 
        require(cur_total_supply + _num_tokens <= MAX_TOKENS, "You have Exceeded the Maximum Supply of NFT Collection");

        // A require condition that checks if the balance of the Ethereum is sufficient.
        require(_num_tokens * price <= msg.value, "ETH Balance is Insufficient!!!");

        // Looping through all the tokens to be minted. 
        for (uint256 i = 1; i <= _num_tokens; ++i)
        {
            // Minting the tokens to the owner's name.
            _safeMint(msg.sender, cur_total_supply + i);
        }

        // Updating the record of the amount of NFT each wallet has minted
        //  with the amount of tokens currently just minted. 
        minted_per_wall[msg.sender] += _num_tokens;

        // Updating the "total_supply".
        total_supply += _num_tokens;
    }

    // Declaring a function that can only be called by the owner by using "onlyOwner".
    function flip_sale_state() external onlyOwner
    {
        // Setting the sale to inactive when it is active,
        // and to active when it is inactive. 
        is_sale_active = !is_sale_active;
    }

    // Declaring a function that takes a string and sets the "Base_uri".
    function set_base_uri(string memory _base_uri) external onlyOwner
    {
        base_uri = _base_uri;
    }

    // Declaring a function that takes in a number and set the number to the price.
    function set_price(uint256 _price) external onlyOwner
    {
        price = _price;
    }

    // Declaring a function "withdraw_all" that withdraws all the ethereum from
    // the smart contract and split it into two wallets. 
    function withdraw_all() external payable onlyOwner
    {
        // Getting the Ethereum balance of the smart contract. 
        uint256 bal = address(this).balance;

        // Splitting the balance into two. 
        uint256 bal_one = bal * 50 / 100;
        uint256 bal_two = bal * 50 / 100;

        // Transferring the Ethereum with the corresponding ratios to each wallet. 
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