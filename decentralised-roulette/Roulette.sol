// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Roulette is ERC20 {
    struct Bet {
        address bettor;
        uint256 betAmount;
        uint256 detail;
    }

    uint256 private nonce = 0;

    Bet[] public onEven;

    Bet[] public onOdd;

    Bet[] public onDigit;

    address public owner;

    uint256 public SpinWheelResult;
    bool public spinned;

    mapping(address => uint256) public balances;

    constructor() ERC20("Roulette", "RLT") {
        owner = msg.sender;
    }

    function setSpinWheelResult(uint256 key) public {
        SpinWheelResult = key;
    }

    function buyTokens() public payable {
        require(msg.value > 0);
        uint256 amount = (msg.value *1000/ (10**18));
        _mint(msg.sender,amount);
    }

    function placeBetEven(uint256 betAmount) public {
        require(balanceOf(msg.sender) >= betAmount, "Insufficient funds");
        _burn(msg.sender, betAmount);
        onEven.push(Bet(msg.sender, betAmount, 0));
    }

    function placeBetOdd(uint256 betAmount) public {
        require(balanceOf(msg.sender) >= betAmount, "Insufficient funds");
        _burn(msg.sender, betAmount);
        onOdd.push(Bet(msg.sender, betAmount, 0));
    }

    function placeBetOnNumber(uint256 betAmount, uint256 number) public {
        require(balanceOf(msg.sender) >= betAmount, "Insufficient funds");
        _burn(msg.sender, betAmount);
        onDigit.push(Bet(msg.sender, betAmount, number));
    }

    function spinWheel() public {
        require(msg.sender == owner);
        SpinWheelResult =
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
            ) %
            37;
        nonce++;
        spinned = true;
    }

    function sellTokens(uint256 tokenAmount) public {
        require(balanceOf(msg.sender) >= tokenAmount);
        _burn(msg.sender, tokenAmount);
        payable(msg.sender).transfer(tokenAmount*(10**18)/1000);
    }

    function transferWinnings() public {
        require(msg.sender == owner && spinned);
        if (SpinWheelResult % 2 == 0) {
            for (uint256 i = 0; i < onEven.length; ++i) {
                address bettor = onEven[i].bettor;
                uint256 winAmout = onEven[i].betAmount +
                    (onEven[i].betAmount * 80000000) /
                    100000000;
                _mint(bettor, winAmout);
            }
        } else {
            for (uint256 i = 0; i < onOdd.length; ++i) {
                address bettor = onOdd[i].bettor;
                uint256 winAmout = onOdd[i].betAmount +
                    (onOdd[i].betAmount * 80000000) /
                    100000000;
                _mint(bettor, winAmout);
            }
        }

        for(uint256 i = 0; i < onDigit.length; ++i) {
            if(onDigit[i].detail == SpinWheelResult) {
                address bettor = onDigit[i].bettor;
                uint256 winAmout = onDigit[i].betAmount + (onDigit[i].betAmount * 1800000000) /100000000 ;
                _mint(bettor, winAmout);
            }
        }
        delete onEven;
        delete onOdd;
        delete onDigit;
    }

    function checkBalance() public view returns (uint256) {
        return balanceOf(msg.sender) ;
    }

    function checkWinningNumber() public view returns (uint256) {
        require(spinned);
        return SpinWheelResult;
    }

    function checkBetsOnEven()
        public
        view
        returns (address[] memory bettor, uint256[] memory amount)
    {
        bettor = new address[](onEven.length);
        amount = new uint256[](onEven.length);
        for (uint256 i =0; i < onEven.length; ++i) {
            bettor[i] = onEven[i].bettor;
            amount[i] = onEven[i].betAmount;
        }
    }

    function checkBetsOnOdd()
        public
        view
        returns (address[] memory bettor, uint256[] memory amount)
    {
        bettor = new address[](onOdd.length);
        amount = new uint256[](onOdd.length);
        for (uint256 i = 0; i < onOdd.length; ++i) {
            bettor[i] = onOdd[i].bettor;
            amount[i] = onOdd[i].betAmount;
        }
    }

    function checkBetsOnDigits()
        public
        view
        returns (
            address[] memory bettor,
            uint256[] memory number,
            uint256[] memory amount
        )
    {
        bettor = new address[](onDigit.length);
        number = new uint256[](onDigit.length);
        amount = new uint256[](onDigit.length);
        for (uint256 i =0; i < onDigit.length; ++i) {
            bettor[i] = onDigit[i].bettor;
            number[i] = onDigit[i].detail;
            amount[i] = onDigit[i].betAmount;
        }
    }
}
