pragma solidity 0.8.4;

contract Ownable {
    address public _owner;

    constructor() {
        _owner = msg.sender;
    }

    // Throws if called by any account other than the owner
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    // Returns true if the caller is the current owner
    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }
}
