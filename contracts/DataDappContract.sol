pragma solidity 0.8.4;

import "./Registry.sol";

contract DataDappContract is Registry {
    //Structs
    struct UploadPacket {
        address ownerAddress;
        bytes32[] ipfsHashes;
    }

    struct Purchase {
        bytes32 packetId;
        address requesterAddress;
        string[] keys;
    }

    struct Review {
        string reviewer;
        uint8 rating;
        bytes32 comments;
    }

    //Mappings
    mapping(bytes32 => UploadPacket) public uploads;
    mapping(bytes32 => bytes32[]) public sampleRequests;
    uint256 nonce;
    mapping(bytes32 => Purchase) public purchases;
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => Review[]) public reviews;

    //Events
    event UploadResult(UploadPacket upload);
    event SampleRequestResult(
        address requester,
        bytes32 sampleRequestId,
        bytes32[] sampleRequestData,
        uint256 index
    );
    event DepositEvent(address requester);
    event SendMoneyEvent(address requester);
    event ReturnMoneyEvent(address requester);
    event ReviewResult(Review review);

    event Test(bytes32 index);
    event Test2(uint256 index);

    //Upload
    function addUpload(
        string memory _userId,
        string memory _packetId,
        string[] memory _ipfsHashes
    ) public registered(_userId) {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        uploads[index].ownerAddress = msg.sender;

        for (uint8 i = 0; i < _ipfsHashes.length; i++) {
            uploads[index].ipfsHashes.push(
                keccak256(abi.encodePacked(_ipfsHashes[i]))
            );
        }

        emit UploadResult(uploads[index]);
    }

    //Probably Unecessary
    function getUploadPacket(string memory _packetId)
        public
        view
        returns (UploadPacket memory)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index];
    }

    //Probably Unecessary
    function getUploadPacketIPFSHashes(string memory _packetId)
        public
        view
        returns (bytes32[] memory)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index].ipfsHashes;
    }

    //Probably Unecessary
    function getUploadPacketOwnerAddress(string memory _packetId)
        public
        view
        returns (address)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index].ownerAddress;
    }

    // Sample
    function addSampleRequest(
        string memory _requesterId,
        string memory _packetId,
        string[] memory _keys
    ) public registered(_requesterId) {
        bytes32 index = keccak256(abi.encodePacked(_packetId, msg.sender));
        for (uint8 i = 0; i < _keys.length; i++) {
            sampleRequests[index].push(keccak256(abi.encodePacked(_keys[i])));
        }
        emit SampleRequestResult(
            msg.sender,
            index,
            sampleRequests[index],
            getRandomKeyIndexTest(sampleRequests[index].length)
        );
    }

    //Probably Unecessary
    function getSampleRequestKeys(bytes32 sampleRequestId)
        public
        view
        returns (bytes32[] memory)
    {
        return sampleRequests[sampleRequestId];
    }

    function getRandomKeyIndexTest(uint256 mod) internal returns (uint256) {
        uint256 rand =
            uint256(
                keccak256(
                    abi.encodePacked(
                        nonce,
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % mod;
        nonce++;
        return rand;
    }

    //Purchase
    function addPurchase(
        string memory _ownerId,
        string memory _packetId,
        address _requesterAddress,
        string[] memory _keys,
        uint256 price,
        bool _approve
    ) public registered(_ownerId) {
        bytes32 index = keccak256(abi.encodePacked(_requesterAddress));

        if (_approve && hashKeysAndCompare(index, _keys)) {
            purchases[index].packetId = keccak256(abi.encodePacked(_packetId));
            purchases[index].requesterAddress = _requesterAddress;

            for (uint8 i = 0; i < _keys.length; i++) {
                purchases[index].keys.push(_keys[i]);
            }
            sendMoney(_requesterAddress, payable(msg.sender), price);
        } else {
            returnMoney(payable(_requesterAddress), price);
        }
    }

    function hashKeysAndCompare(bytes32 _index, string[] memory _keysFromSeller)
        internal
        view
        returns (bool)
    {
        bytes32[] memory keysFromSample = getSampleRequestKeys(_index);
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

    receive() external payable {
        bytes32 index = keccak256(abi.encodePacked(msg.sender));
        deposits[index] += msg.value;
        emit DepositEvent(msg.sender);
    }

    function depositMoney(string memory _packetId, uint256 _value)
        public
        payable
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId, msg.sender));
        deposits[index] += _value;
        emit DepositEvent(msg.sender);
    }

    function sendMoney(
        address from,
        address payable _to,
        uint256 price
    ) internal {
        bytes32 index = keccak256(abi.encodePacked(from));
        require(price <= deposits[index], "Not enough money sent");
        uint256 moneyToSent = price;
        deposits[index] -= price;
        _to.transfer(moneyToSent);

        emit SendMoneyEvent(_to);
    }

    function returnMoney(address payable _to, uint256 price) internal {
        bytes32 index = keccak256(abi.encodePacked(_to));
        require(price <= deposits[index], "Not enough money in deposit");
        uint256 moneyToSent = price;
        deposits[index] -= price;
        _to.transfer(moneyToSent);

        emit ReturnMoneyEvent(_to);
    }

    function getPurchaseKeys(
        string memory _requesterId,
        string memory _packetId
    ) public view registered(_requesterId) returns (string[] memory) {
        bytes32 index = keccak256(abi.encodePacked(_packetId, msg.sender));
        return purchases[index].keys;
    }

    //Review
    function addReview(
        string memory _rated,
        string memory _reviewer,
        uint8 _rating,
        string memory _comments
    ) public registered(_rated) registered(_reviewer) {
        Review memory review =
            Review(_reviewer, _rating, keccak256(abi.encodePacked(_comments)));
        reviews[keccak256(abi.encodePacked(_rated))].push(review);

        emit ReviewResult(review);
    }

    //Probably Unecessary
    function getReviews(string memory _rated)
        public
        view
        returns (Review[] memory)
    {
        return reviews[keccak256(abi.encodePacked(_rated))];
    }

    function getDeposit(address _address) public {
        emit Test2(deposits[keccak256(abi.encodePacked(_address))]);
    }
}
