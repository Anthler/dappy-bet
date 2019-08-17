import React, { Component } from "react";

import web3 from "../web3";
import DappyBetInstance from "../DappyBet";

//import MultipleSelect from "./MultiSelect";

class AddGame extends Component {
  state = {
    showCreateGameForm: false,
    account: "",
    teams: [],
    lockDate: 0
  };

  // async createGame(lockTime, involvedTeams) {
  //   const accounts = await web3.eth.getAccounts();
  //   await DappyBetInstance.methods
  //     .createGame(lockTime, involvedTeams)
  //     .send({ from: accounts[0] });
  // }

  // updateDate = event => {
  //   this.setState({ lockDate: event.target.value });
  //   console.log(this.state.lockDate);
  // };

  render() {
    return (
      <div>
        <div>
          <h3>Create New Game</h3>
        </div>
      </div>
    );
  }
}

export default AddGame;
