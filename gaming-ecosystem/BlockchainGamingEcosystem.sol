// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGamingEcosystemNFT {
    function mintNFT(address to) external;

    function burnNFT(uint256 tokenId) external;

    function transferNFT(
        uint256 tokenId,
        address from,
        address to
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);
}

contract BlockchainGamingEcosystem {
    address public owner;

    // User Information
    mapping(string => bool) public usernameExisted;
    mapping(address => string) public accountOf;
    mapping(address => uint256) public balanceOf;

    // Game Information
    mapping(uint256 => string) game;
    mapping(uint256 => bool) isIdExist;
    mapping(string => bool) isNameExist;
    mapping(uint256 => uint256) priceOfAsset;

    // NFT Information
    IGamingEcosystemNFT public NFT;
    mapping(uint256 => uint256) nftBelongToGame;

    //game id => price
    mapping(uint256 => uint256) priceOfNFT;
    uint256 public nftIndex = 0;

    constructor(address _nftAddress) {
        NFT = IGamingEcosystemNFT(_nftAddress);
        owner = msg.sender;
    }

    modifier Registered() {
        require(usernameExisted[accountOf[msg.sender]]);
        _;
    }

    // Function to register as a player
    function registerPlayer(string memory userName) public {
        require(bytes(userName).length >= 3);
        require(!usernameExisted[userName]);
        require(!usernameExisted[accountOf[msg.sender]]);
        require(msg.sender != owner);
        usernameExisted[userName] = true;
        accountOf[msg.sender] = userName;
        balanceOf[msg.sender] = 1000;
    }

    // Function to create a new game
    function createGame(string memory gameName, uint256 gameID) public {
        require(msg.sender == owner);
        require(!isIdExist[gameID]);
        require(!isNameExist[gameName]);
        game[gameID] = gameName;
        isIdExist[gameID] = true;
        isNameExist[gameName] = true;
    }

    // Function to remove a game from the ecosystem
    function removeGame(uint256 gameID) public {
        require(msg.sender == owner);
        require(isIdExist[gameID]);
        isIdExist[gameID] = false;
        isNameExist[game[gameID]] = false;
        delete (game[gameID]);
        priceOfAsset[gameID] = 0;
        for (uint256 i = 0; i < nftIndex; ++i) {
            if (nftBelongToGame[i] == gameID) {
                try NFT.ownerOf(i) {
                    address ownerOfNFTBurned = NFT.ownerOf(i);
                    balanceOf[ownerOfNFTBurned] += priceOfNFT[i];
                } catch { continue;}
                try NFT.burnNFT(i) {} catch { continue;}
            }
        }
    }

    // Function to add an NFT asset to the ecosystem
    function addNFT(uint256 gameID, string memory name) public {
        require(!isIdExist[gameID]);
        isNameExist[name] = true;
        createGame(name, gameID);
    }

    // Function to allow players to buy an NFT asset
    function buyAsset(uint256 gameID) public Registered {
        require(isIdExist[gameID]);

        uint256 currentPrice = priceOfAsset[gameID];
        if (currentPrice == 0) {
            currentPrice = 250;
        }

        require(balanceOf[msg.sender] >= currentPrice);
        balanceOf[msg.sender] -= currentPrice;

        NFT.mintNFT(msg.sender);
        nftBelongToGame[nftIndex] = gameID;
        priceOfNFT[nftIndex] = currentPrice;

        priceOfAsset[gameID] = currentPrice + (currentPrice * 10000000 / 100000000); 

        nftIndex++;
    }


    // Function to allow players to sell owned assets
    function sellAsset(uint256 tokenID) public Registered {
        require(NFT.ownerOf(tokenID) == msg.sender);
        balanceOf[msg.sender] += priceOfAsset[nftBelongToGame[tokenID]];
        NFT.burnNFT(tokenID);
    }

    // Function to transfer asset to a different player
    function transferAsset(uint256 tokenID, address to) public {
        require(NFT.ownerOf(tokenID) == msg.sender);
        require(usernameExisted[accountOf[to]]);
        require(to != msg.sender);
        require(to != owner);
        NFT.transferNFT(tokenID, msg.sender, to);
    }

    // Function to view a player's profile
    function viewProfile(address playerAddress)
        public
        view
        returns (
            string memory userName,
            uint256 balance,
            uint256 numberOfNFTs
        )
    {
        require(msg.sender == owner || usernameExisted[accountOf[msg.sender]]);
        require(playerAddress != owner, "Invalid: owner address");

        userName = accountOf[playerAddress];
        balance = balanceOf[playerAddress];
        numberOfNFTs = 0;
        for (uint256 i = 0; i < nftIndex; ++i) {
            try NFT.ownerOf(i) returns (address tokenOwner) {
                if (tokenOwner == playerAddress) {
                    numberOfNFTs++;
                }
            } catch {
                continue;
            }
        }
    }


    // Function to view Asset owner and the associated game
    function viewAsset(uint256 tokenID)
        public
        view
        returns (
            address ownerOfNFT,
            string memory name,
            uint256 price
        )
    {
        require(msg.sender == owner || usernameExisted[accountOf[msg.sender]]);
        try NFT.ownerOf(tokenID) {
          ownerOfNFT = NFT.ownerOf(tokenID);
        } catch {
            revert();
        }
        name = game[nftBelongToGame[tokenID]];
        price = priceOfNFT[tokenID];
    }
}
