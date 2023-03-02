// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MyERC20Token.sol";

contract TicketTest31 is ERC721 {
    uint256 public constant TOTAL_TOKEN_SUPPLY = 10000;
    uint256 public tokenCount;
    mapping(address => uint256) public nftTokenBalances;
    mapping(address => uint256) public TokenBalances;

    uint256 public tokenId;
    MyERC20Token public token;
    address public owner;

    constructor(address tokenAddress) ERC721("TicketingProtocol", "TICKET") {
        tokenId = 0;
        tokenCount = 0;
        token = MyERC20Token(tokenAddress);
        owner = msg.sender;
    }

    function tokenBalance(address addr) public view returns (uint256) {
        return token.balanceOf(addr);
    }

    function tokenBalanceContract() public view returns (uint256) {
        return token.balanceOf(address(token));
    }

    function buyTicket(uint256 price) external {
        require(tokenCount + price < TOTAL_TOKEN_SUPPLY, "No tokens left");

        uint256 tokenPrice = 1 ether;
        uint256 tokensToTransfer = price * tokenPrice;

        tokenCount += tokensToTransfer;
        tokenId++;
        _mint(msg.sender, tokenId);
        nftTokenBalances[msg.sender] = tokensToTransfer;

        token.transfer(msg.sender, tokensToTransfer);
    }

    function buyTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(tokenCount + amount < TOTAL_TOKEN_SUPPLY, "No tokens left");

        tokenCount += amount;
        token.transferFrom(msg.sender, address(this), amount);
        TokenBalances[msg.sender] += amount;
    }

    function transferToProtocolWall(address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "You are not the owner of this token"
        );

        uint256 unusedTokens = nftTokenBalances[msg.sender];
        TokenBalances[to] += unusedTokens;
        nftTokenBalances[msg.sender] = 0;
    }

    function buyWithTokens(address seller, uint256 amount) public {
        require(TokenBalances[msg.sender] >= amount, "Insufficient funds");
        require(
            TokenBalances[seller] + amount > TokenBalances[seller],
            "Overflow"
        );

        TokenBalances[msg.sender] -= amount;
        TokenBalances[seller] += amount;
        token.transfer(seller, amount);
    }

    function withdraw() external {
        uint256 amount = TokenBalances[msg.sender];
        require(amount > 0, "Insufficient balance");
        tokenCount -= amount;
        TokenBalances[msg.sender] = 0;
        token.transfer(msg.sender, amount);
    }
}
