# Decentralized Raffle
# Description
This is a smart contract for a decentralized raffle system that allows users to enter with a specified entrance fee. A winner is selected randomly using Chainlink VRF (Verifiable Random Function), ensuring fairness. The contract also utilizes Chainlink Automation to automate the winner selection process.
## Features
- Users can enter the raffle by sending the required entrance fee.
- The contract restricts new entries during the winner selection process.
- The entire contract balance is sent to the winner upon selection.
