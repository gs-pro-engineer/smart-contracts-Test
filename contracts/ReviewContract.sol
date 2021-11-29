pragma solidity 0.8.4;

import "./Registry.sol";

contract ReviewContract is Registry {
    struct Review {
        string reviewer;
        uint8 rating;
        bytes32 comments;
    }

    mapping(bytes32 => Review[]) public reviews;

    event ReviewResult(Review _review);

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

    function getReviews(string memory _rated)
        public
        view
        returns (Review[] memory)
    {
        return reviews[keccak256(abi.encodePacked(_rated))];
    }
}
