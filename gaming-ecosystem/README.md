# Blockchain Gaming Ecosystem DApp-World

This repository contains the smart contract for a blockchain-based gaming ecosystem. The ecosystem comprises players, games, credits, and non-fungible tokens (NFTs) that represent in-game assets.

## Overview

The smart contract enables players to register, purchase in-game assets (NFTs), and interact with these assets. It also manages game creation and removal, asset ownership, and transfers within the ecosystem.

## Rules

- **Owner & Deployer**
  - The deployer of the contract is made the owner.
- **Player Registration**
  - Anyone can register as a player in the ecosystem, except for the owner.
  - A registered player receives 1000 credits upon successful registration.
  - Each player must have a unique user name with a minimum length of 3 characters.
- **NFTs (In-Game Assets)**
  - The tokenID of the NFTs starts from 0 and increments by 1 each time a new NFT is minted.
- **Game Management**
  - The owner can create new games at any time after the contract deployment.
  - The owner can also remove any game from the ecosystem. When a game is removed:
    - All assets (NFTs) associated with the game are destroyed.
    - Players owning assets in the game are refunded the credits they used to purchase those assets.
- **Asset Transactions**
  - Players can use credits to buy and sell in-game assets.
  - Players are allowed to transfer their assets to any other registered player.

## Smart Contract Functions

### Constructor

- **`constructor(address _nftAddress)`**
  - Initializes the contract by taking a single parameter of type `address` which is the address of the deployed NFT smart contract.

### Player Registration

- **`registerPlayer(string userName)`**
  - Accessible by everyone except the owner.
  - Registers a player into the ecosystem provided that the same address has not been registered before.
  - The `userName` must be unique and have at least 3 characters.
  - Upon successful registration, the player receives 1000 credits.

### Game Management

- **`createGame(string gameName, uint256 gameID)`**
  - Only accessible by the owner.
  - Creates a new game with unique `gameName` and `gameID`.
  
- **`removeGame(uint256 gameID)`**
  - Only accessible by the owner.
  - Removes a game from the ecosystem.
  - Destroys all assets associated with the game.
  - Refunds players the credits that were used to buy the assets from the removed game.

### Asset Operations

- **`buyAsset(uint256 gameID)`**
  - Accessible to all registered players.
  - A player can buy an asset (an NFT) corresponding to a particular game using their credits.
  - The price for the first asset of any game is 250 credits.
  - Every time an asset is purchased, the price increments by 10% for subsequent purchases. If the calculated price includes decimals, it will be truncated (rounded down) before applying the 10% increment.
  - Each purchase mints a new NFT with the player as the owner.

- **`sellAsset(uint256 tokenID)`**
  - Accessible by all registered players.
  - Allows a player to sell their asset. The asset is destroyed, and the player gets refunded credits equivalent to the current buying price of the asset for that particular game.

- **`transferAsset(uint256 tokenID, address to)`**
  - Accessible by all registered players.
  - Allows a player to transfer their asset to any other registered player.

### Query Functions (Output)

- **`viewProfile(address playerAddress) returns (string userName, uint256 balance, uint256 numberOfNFTs)`**
  - Can be called by any registered player or by the owner.
  - Returns the player's name, current balance, and the total number of NFTs (in-game assets) the player holds.

- **`viewAsset(uint256 tokenID) returns (address player, string gameName, uint price)`**
  - Accessible by any registered player or by the owner.
  - Returns details of the asset: the owner's address, the game name with which the asset is associated, and the purchase price of the asset.

## How to Use

1. **Deployment**
   - Deploy the NFT smart contract first.
   - Deploy the Blockchain Gaming Ecosystem smart contract by passing the NFT contract address to its constructor.
2. **Registration**
   - Players can register by calling `registerPlayer()` with a unique user name.
3. **Game Management (Owner Only)**
   - The owner can create new games with `createGame()` and remove existing games using `removeGame()`.
4. **Asset Transactions**
   - Registered players can buy assets using `buyAsset()`, sell them using `sellAsset()`, and transfer assets to other players via `transferAsset()`.
5. **Querying**
   - Use `viewProfile()` to check player details.
   - Use `viewAsset()` to fetch details about a specific asset.

## Contribution

Contributions are welcome. Feel free to fork the repository and submit pull requests with improvements, bug fixes, or additional features.

