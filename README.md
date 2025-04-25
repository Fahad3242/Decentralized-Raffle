# Raffle Smart Contract Project

This project is a full-stack decentralized application (dApp) built for an on-chain Raffle system. It includes smart contract development, automated testing, and deployment scripts, designed for deployment and testing on Ethereum testnets like Sepolia.

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
- [Hardhat/Anvil] (optional for local testing)
- **Alchemy** or **Infura** for Sepolia RPC

---

## 🚀 Deployment

### Deploy to Sepolia:

1. Set your environment variables:

```bash
export PRIVATE_KEY=your_wallet_private_key
export SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY
