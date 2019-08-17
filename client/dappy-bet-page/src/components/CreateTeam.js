import React, { Component } from "react";
import web3 from "../web3";
import DappyBetInstance from "../DappyBet";

class CreateTeam extends Component {
  state = {};

  async createNewTeam(name) {
    const accounts = await web3.eth.getAccounts();
    await DappyBetInstance.methods.createTeam(name).send({ from: accounts[0] });
    this.setState({ teamName: "" });
  }

  render() {
    return (
      <div>
        <h2>Add New Team</h2>
      </div>
    );
  }
}

export default CreateTeam;
