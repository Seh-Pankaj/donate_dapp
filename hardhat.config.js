// eslint-disable-next-line @typescript-eslint/no-require-imports
require("dotenv").config();

const SEPOLIA_URL = process.env.SEPOLIA_RPC_URL || "https://sepolia.com";
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "key";

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    sepolia: {
      url: SEPOLIA_URL,
      chainId: 11155111,
      blockConfirmations: 2,
    },
  },
  solidity: "0.8.27",
  gasReporter: {
    enabled: true,
    outputFile: "gas-reporter.txt",
    noColors: true,
    currency: "INR",
    coinmarketcap: COINMARKETCAP_API_KEY,
  },
};
