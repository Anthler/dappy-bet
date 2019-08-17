import web3 from "./web3";
import DappyBetABI from "./contracts/DappyBet.json";

const DappyBetContractAddress = "0x9197ed64f7ddac46820dd47ace8edbd6b3c26c29";

const DappyBetInstance = new web3.eth.Contract(
  DappyBetABI,
  DappyBetContractAddress
);

console.log(DappyBetInstance.methods);

export default DappyBetInstance;
