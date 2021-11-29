pragma solidity 0.8.4;

contract Registry {
    mapping(bytes32 => bool) public registeredUsers;

    event Register(string _id);
    event Check(bool _isRegistered);

    function registerUser(string memory _id) public {
        registeredUsers[keccak256(abi.encodePacked(_id))] = true;
        emit Register(_id);
    }

    // Throws if user passed as a parameter is not registered
    modifier registered(string memory _id) {
        require(
            registeredUsers[keccak256(abi.encodePacked(_id))] == true,
            "User is not registered"
        );
        _;
    }

    function getRegisterUsers(string memory _id) public {
        emit Check(registeredUsers[keccak256(abi.encodePacked(_id))]);
    }
}
