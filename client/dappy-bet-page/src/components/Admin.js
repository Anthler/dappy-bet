import React, { Component } from "react";
import web3 from "../web3";
import DappyBetInstance from "../DappyBet";

import TabPanel from "./Tabs";

class Admin extends Component {
  state = {
    account: "",
    game: {},
    gameId: null,
    games: [],
    teamName: "",
    gameResults: {},
    winner: null,
    scores: [],
    date: null
  };

  render() {
    return (
      <div>
        <div className="">
          <TabPanel />
        </div>
      </div>
    );
  }
}

export default Admin;
