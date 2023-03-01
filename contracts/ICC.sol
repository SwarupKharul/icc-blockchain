// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ICC is ERC721 {
    uint256 public constant TOTAL_TOKEN_SUPPLY = 10000;
    uint256 public tokenCount;
    mapping(address => uint256) public nftTokenBalances;
    mapping(address => uint256) public TokenBalances;

    uint256 public tokenId;

    constructor() ERC721("TicketingProtocol", "TICKET") {
        tokenId = 0;
        tokenCount = 0;
    }

    function buyTicket(uint256 price)
        external
        payable
    {
        require(tokenCount + price < TOTAL_TOKEN_SUPPLY, "No tokens left");
        // require(msg.value == price, "Incorrect payment amount");

        tokenCount += price;
        (bool success, ) = msg.sender.call{value: msg.value}("");
        require(success, "Token transfer to buyer failed.");
        tokenId++;
        _mint(msg.sender, tokenId);
        nftTokenBalances[msg.sender] = price;
    }

    function buyTokens(uint256 price) external payable {
        // require(msg.value > 0, "Insufficient funds sent");
        require(tokenCount + price < TOTAL_TOKEN_SUPPLY, "No tokens left");
        tokenCount += price;

        TokenBalances[msg.sender] += price;
    }

    function transferToProtocol(address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "You are not the owner of this token"
        );

        uint256 unusedTokens = nftTokenBalances[msg.sender];
        TokenBalances[to] += unusedTokens;
    }

    function buyWithTokens(address seller, uint256 amount) public {
        require(TokenBalances[msg.sender] >= amount, "Insufficient funds");
        require(
            TokenBalances[seller] + amount > TokenBalances[seller],
            "Overflow"
        );

        TokenBalances[msg.sender] -= amount;
        TokenBalances[seller] += amount;
    }

    function withdraw() external payable {
        uint256 amount = TokenBalances[msg.sender];
        require(amount > 0, "Insufficient balance");
        tokenCount -= amount;
        TokenBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
