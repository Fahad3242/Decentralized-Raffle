# 🎲 Raffle Contract

Welcome to the **Raffle** project!  
This smart contract system allows users to enter a decentralized, autonomous raffle, leveraging **Chainlink VRF v2.5** for verifiable randomness and **Chainlink Automation** for upkeep.

---

## ✨ Features

- Decentralized raffle entry with ETH
- Verifiable randomness using Chainlink VRF v2.5
- Automated upkeep through Chainlink Keepers
- Supports local and Sepolia testnet deployments
- Fully tested using Foundry

---

## 📂 Project Structure

| File | Purpose |
|:----|:--------|
| `src/Raffle.sol` | Core Raffle contract logic |
| `script/DeployRaffle.s.sol` | Script to deploy Raffle contract |
| `script/HelperConfig.s.sol` | Network-specific configurations |
| `script/Interactions.s.sol` | VRF subscription interactions (create, fund, add consumer) |
| `test/unit/RaffleTest.t.sol` | Unit tests for Raffle functionality |
| `test/mocks/LinkToken.sol` | Mock Link token for local testing |
| `foundry.toml` | Foundry configuration file |

---

## ⚙️ Contract Overview

### `Raffle.sol`
- Users can enter by paying a minimum `entranceFee`.
- Periodic checks via Chainlink Automation (Keepers) determine if it's time to pick a winner.
- Chainlink VRF is used to obtain randomness for winner selection.
- ETH balance is awarded to the winner and the raffle resets.

---

## 🛠️ How to Deploy

### 1. Install dependencies
```bash
forge install
```

### 2.Deploy to network
```
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast --verify

```
### 3. Local Deployment Notes
- Automatically deploys VRFCoordinator and LinkToken mocks.
- Automatically creates and funds VRF subscription locally.
- Automatically adds the deployed Raffle contract as a VRF consumer.

### 4. Testnet Deployment Notes
- Uses real Chainlink VRF Coordinator, LinkToken, and Subscription ID.
- If needed, create and fund a subscription separately using scripts.

## 🧪 Running Tests

- Run unit tests:
``` bash
    
forge test -vv

```
- Run tests against a forked Sepolia:

``` bash
forge test --fork-url <SEPOLIA_RPC_URL> -vv

```
## 📜 Chainlink VRF Integration

### VRF Coordinator:

- Local: Mocked

- Sepolia: Real Chainlink VRF Coordinator

### Randomness Flow:

- `performUpKeep()` requests random words.

- Chainlink VRF responds via `fulfillRandomWords()`.

- A random player is selected and wins the prize pool.

### Subscription Management:

- Create subscriptions with `CreateSubscription.s.sol`

- Fund subscriptions with `FundSubscription.s.sol`

- Add consumer contracts with `AddConsumer.s.sol`

## 🧩 Important Scripts

| Script | Purpose |
| --- | --- |
| `CreateSubscription.s.sol` | Create a new VRF subscription |
| `FundSubscription.s.sol` | Fund a VRF subscription with LINK |
| `AddConsumer.s.sol` | Add Raffle contract as a consumer to the VRF subscription |

## 🔑 Configurations (`HelperConfig.s.sol`)

Supports two environments:

- **Local Anvil network**
  - Mocks deployed for VRFCoordinator and LinkToken
  - Subscription is automatically created and funded

- **Sepolia Testnet**
  - Preconfigured addresses for VRF Coordinator, LINK token, and gas lanes
  - Real subscription ID required

> To add support for a new network, modify `HelperConfig.s.sol` accordingly.

---

## 📈 Future Enhancements

- Frontend dApp to interact with the raffle
- Chainlink VRF fulfillment automation for local testing
- Multiple winners feature
- Prize pool splitting
- Gas optimizations

---

## 👨‍💻 Author

- **Muhammad Fahad**




