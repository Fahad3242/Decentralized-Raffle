# Raffle Smart Contract Project

- This project is a full-stack decentralized application (dApp) built for an on-chain Raffle system. It includes smart contract development, automated testing, and deployment scripts, designed for deployment and testing on Ethereum testnets like Sepolia.

---

## 📦 Project Structure

| Folder / File                 | Purpose                                                           |
| ---------------------------- | ----------------------------------------------------------------- |
| `contracts/Raffle.sol`        | Main Raffle contract logic                                        |
| `script/DeployRaffle.s.sol`   | Deployment script for Raffle contract                             |
| `script/HelperConfig.s.sol`   | Network configuration (e.g., Chainlink VRF settings)              |
| `script/Interactions.s.sol`   | Interaction script for adding consumer to VRF subscription        |
| `test/unit/RaffleTest.t.sol`  | Unit tests for Raffle contract                                    |

---

## ⚙️ Technologies Used

- **Solidity**
- **Foundry** (Forge, Anvil)
- **Chainlink VRF v2**
- **Sepolia Testnet**
- **Hardhat/Anvil** (optional for local testing)
- **Alchemy** or **Infura** for Sepolia RPC

---

## 🚀 Deployment

### Deploy to Sepolia:

#### 1. Set your environment variables:

```bash
export PRIVATE_KEY=your_wallet_private_key
export SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY
```
#### 2. Run the deployment script:

```bash
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```
- `--broadcast`: sends the transaction  
- `--verify`: verifies the contract on Etherscan  
- `-vvvv`: sets verbose logging level  

---

## 🧪 Testing

### Run unit tests locally:

```bash
forge test
```
### Run tests against a forked Sepolia chain:

```bash
forge test --fork-url https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY -vvvv
```
> ⚡ **Note**: Forked tests may require impersonation to interact with Chainlink VRF subscriptions.

---

## 🛠️ Scripts Summary

- `DeployRaffle.s.sol`: Deploys the Raffle contract and sets it up with Chainlink VRF.
- `HelperConfig.s.sol`: Supplies network-specific constants (e.g., VRF Coordinator, Gas Lane, Subscription ID).
- `Interactions.s.sol`: Adds the deployed Raffle contract as a consumer to Chainlink VRF subscription.

---

## 📜 Raffle Contract Features

- Users enter the raffle by paying an entrance fee.
- Chainlink VRF is used to randomly select a winner.
- Draws occur on a timed interval.
- Uses LINK token for randomness requests.

---

## ⚡ Chainlink Integration

- **VRF Coordinator Address** (Sepolia):  
  `0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B`

- Other config (gas lane, subscription ID, etc.) is provided in `HelperConfig.s.sol`.

---

## 🧹 Notes

- Forked tests use real Sepolia state but are **run locally**.
- Use `vm.startPrank(ownerAddress)` during forked testing to impersonate subscription owners.
- Always ensure your Sepolia subscription is funded when testing randomness.



