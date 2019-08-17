import React, { Component } from "react";
import web3 from "./web3";
import DappyBetInstance from "./DappyBet";
import AppNavBar from "./components/Header";
import AllGames from "./components/AllGames";
import AddGame from "./components/AddGame";
//import "./App.css";

class App extends Component {
  render() {
    return (
      <div className="text-center">
        <AppNavBar />
        <br />
        <div className="container text-center">
          <AllGames />
        </div>
      </div>
    );
  }
}

export default App;
