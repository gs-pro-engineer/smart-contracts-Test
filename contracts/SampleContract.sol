pragma solidity 0.8.4;

import "./Registry.sol";

contract SampleContract is Registry {
    mapping(bytes32 => bytes32[]) public sampleRequests;
    uint256 nonce;

    event SampleRequestResult(address requester, uint256 index);

    function addSampleRequest(
        string memory _userId,
        string memory _packetId,
        string[] memory _keys
    ) public registered(_userId) {
        bytes32 index = keccak256(abi.encodePacked(_packetId, msg.sender));
        for (uint8 i = 0; i < _keys.length; i++) {
            sampleRequests[index].push(keccak256(abi.encodePacked(_keys[i])));
        }
        emit SampleRequestResult(
            msg.sender,
            getRandomKeyIndexTest(sampleRequests[index].length)
        );
    }

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
}
