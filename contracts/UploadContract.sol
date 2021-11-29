pragma solidity 0.8.4;

import "./Registry.sol";

contract UploadContract is Registry {
    struct UploadPacket {
        address ownerAddress;
        bytes32[] ipfsHashes;
    }

    mapping(bytes32 => UploadPacket) public uploads;

    event UploadResult(UploadPacket upload);

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

    function getUploadPacket(string memory _packetId)
        public
        view
        returns (UploadPacket memory)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index];
    }

    function getUploadPacketIPFSHashes(string memory _packetId)
        public
        view
        returns (bytes32[] memory)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index].ipfsHashes;
    }

    function getUploadPacketOwnerAddress(string memory _packetId)
        public
        view
        returns (address)
    {
        bytes32 index = keccak256(abi.encodePacked(_packetId));
        return uploads[index].ownerAddress;
    }
}
