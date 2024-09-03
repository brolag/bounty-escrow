// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Escrow {
    address public funder;
    address public beneficiary;
    uint256 public amount;
    bool public isFunded;
    bool public isReleased;

    event Funded(address funder, address beneficiary, uint256 amount);
    event Released(address beneficiary, uint256 amount);

    constructor() {
        funder = msg.sender;
    }

    function fund(address _beneficiary) public payable {
        require(!isFunded, "Contract is already funded");
        require(msg.value > 0, "Funding amount must be greater than 0");

        beneficiary = _beneficiary;
        amount = msg.value;
        isFunded = true;

        emit Funded(funder, beneficiary, amount);
    }

    function release() public {
        require(msg.sender == funder, "Only the funder can release funds");
        require(isFunded, "Contract is not funded");
        require(!isReleased, "Funds have already been released");

        isReleased = true;
        payable(beneficiary).transfer(amount);

        emit Released(beneficiary, amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
