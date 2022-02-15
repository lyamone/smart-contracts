// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Problem {
    address public proponent;
    
    struct ProblemObj {
        uint256 reward;
        uint256 deadline;
    }

    struct Solver {
        string displayName;
    }
    
    ProblemObj public problem = ProblemObj(0, 0);
    uint256 public solversQuantity = 0;
    mapping (address => Solver) public solvers;
    
    /// Only the proponent can call this function.
    error OnlyProponent();
    /// Only the solver can call this function.
    error OnlySolvers();
    /// The function cannot be called at the current state.
    error InvalidState(string);

    /// Not enough funds to pay.
    error insufficientFunds(string);

    modifier onlyProponent() {
        if (msg.sender != proponent)
            revert OnlyProponent();
        _;
    }

    modifier onlySolvers() {
        if (bytes(solvers[msg.sender].displayName).length == 0)
            revert OnlySolvers();
        _;
    }

    modifier maxAmountOfSolvers() {
        if(solversQuantity >= 5)
            revert InvalidState("The maximum number of solvers is 5.");
        _;
    }

    modifier deadlineNotExpired() {
        if(block.timestamp >= problem.deadline)
            revert InvalidState("The deadline has expired.");
        _;
    }

    constructor(uint256 _reward, uint256 _deadline) {
        problem.reward = getValidRewardOrRevert(_reward);
        problem.deadline = _deadline;
        proponent = msg.sender;
    }

    function addSolver(string memory displayName) public maxAmountOfSolvers deadlineNotExpired {
        require(bytes(displayName).length > 2,"Display name should be at least 3 characters long");
        require(bytes(solvers[msg.sender].displayName).length == 0, "The solver already added a solution");
        solvers[msg.sender].displayName = displayName;
        solversQuantity++;
    }

    function removeSolver(string memory displayName) public {
        require(solversQuantity > 0, "There are no solvers registered.");
        require(keccak256(bytes(solvers[msg.sender].displayName)) == keccak256(bytes(displayName)), "The solver is not registered.");
        solvers[msg.sender].displayName = '';
        solversQuantity--;
    }

    // Check if user has enough funds to pay the reward.
    // Otherwise revert the transaction.
    function getValidRewardOrRevert(uint _reward) private view returns (uint) {
        if(msg.sender.balance > _reward) {
            return _reward;
        } else {
            revert insufficientFunds("You don't have enough money to pay the reward.");
        }
    }
}