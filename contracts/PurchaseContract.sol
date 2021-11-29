pragma solidity 0.8.4;

import "./SampleContract.sol";

contract PurchaseContract is Registry {
    struct Purchase {
        bytes32 packetId;
        address requesterAddress;
        string[] keys;
    }

    mapping(bytes32 => Purchase) public purchases;
    mapping(bytes32 => uint256) public deposits;

    event DepositEvent(address requester);
    event SendMoneyEvent(address requester);
    event ReturnMoneyEvent(address requester);

    function addPurchase(
        string memory _userId,
        string memory _packetId,
        address _requesterAddress,
        string[] memory _keys
    ) public registered(_userId) {
        bytes32 index =
            keccak256(abi.encodePacked(_packetId, _requesterAddress));

        if (hashKeysAndCompare(index, _keys)) {
            purchases[index].packetId = keccak256(abi.encodePacked(_packetId));
            purchases[index].requesterAddress = _requesterAddress;

            for (uint8 i = 0; i < _keys.length; i++) {
                purchases[index].keys.push(_keys[i]);
            }
            sendMoney(_requesterAddress, payable(msg.sender), _packetId);
        } else {
            returnMoney(payable(_requesterAddress), _packetId);
        }
    }

    function hashKeysAndCompare(bytes32 _index, string[] memory _keysFromSeller)
        internal
        returns (bool)
    {
        SampleContract sampleContract = new SampleContract();

        bytes32[] memory keysFromSample =
            sampleContract.getSampleRequestKeys(_index);
        bool confirm = true;

        for (uint8 i = 0; i < keysFromSample.length; i++) {
            if (
                keysFromSample[i] !=
                keccak256(abi.encodePacked(_keysFromSeller[i]))
            ) {
                confirm = false;
            }
        }
        return confirm;
    }

    function depositMoney(string memory _packetId) public payable {
        bytes32 index = keccak256(abi.encodePacked(_packetId, msg.sender));
        deposits[index] += msg.value;
        emit DepositEvent(msg.sender);
    }

    function sendMoney(
        address from,
        address payable _to,
        string memory _packetId
    ) internal {
        bytes32 index = keccak256(abi.encodePacked(_packetId, from));
        uint256 moneyToSent = deposits[index];
        deposits[index] = 0;
        _to.transfer(moneyToSent);

        emit SendMoneyEvent(_to);
    }

    function returnMoney(address payable _to, string memory _packetId)
        internal
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId, _to));
        uint256 moneyToSent = deposits[index];
        deposits[index] = 0;
        _to.transfer(moneyToSent);

        emit ReturnMoneyEvent(_to);
    }

    function getPurchaseKeys(string memory _packetId, address _requesterAddress)
        public
        view
        onlyOwner
        returns (string[] memory)
    {
        bytes32 index =
            keccak256(abi.encodePacked(_packetId, _requesterAddress));
        return purchases[index].keys;
    }
}
