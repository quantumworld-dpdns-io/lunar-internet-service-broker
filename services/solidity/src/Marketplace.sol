// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./LunarRelayToken.sol";

contract Marketplace is AccessControl, ReentrancyGuard {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");

    LunarRelayToken public relayToken;

    struct Offer {
        uint256 id;
        address provider;
        uint256 bandwidthMbps;
        uint256 pricePerMbps;
        uint256 availableFrom;
        uint256 availableUntil;
        string zone;
        bool isActive;
    }

    struct Request {
        uint256 id;
        address operator;
        uint256 bandwidthMbps;
        uint256 maxBudget;
        uint256 requestedFrom;
        uint256 requestedUntil;
        string zone;
        bool isOpen;
    }

    struct Match {
        uint256 id;
        uint256 offerId;
        uint256 requestId;
        uint256 score;
        uint256 allocatedBandwidth;
        uint256 totalPrice;
        uint256 scheduleFrom;
        uint256 scheduleUntil;
    }

    uint256 private _offerCounter;
    uint256 private _requestCounter;
    uint256 private _matchCounter;

    mapping(uint256 => Offer) public offers;
    mapping(uint256 => Request) public requests;
    mapping(uint256 => Match) public matches;

    event OfferCreated(uint256 indexed id, address indexed provider, uint256 bandwidthMbps);
    event RequestCreated(uint256 indexed id, address indexed operator, uint256 bandwidthMbps);
    event MatchCreated(uint256 indexed id, uint256 offerId, uint256 requestId, uint256 totalPrice);

    constructor(address tokenAddress) {
        relayToken = LunarRelayToken(tokenAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    function createOffer(
        uint256 bandwidthMbps,
        uint256 pricePerMbps,
        uint256 availableFrom,
        uint256 availableUntil,
        string calldata zone
    ) external returns (uint256) {
        _offerCounter++;
        offers[_offerCounter] = Offer({
            id: _offerCounter,
            provider: msg.sender,
            bandwidthMbps: bandwidthMbps,
            pricePerMbps: pricePerMbps,
            availableFrom: availableFrom,
            availableUntil: availableUntil,
            zone: zone,
            isActive: true
        });
        emit OfferCreated(_offerCounter, msg.sender, bandwidthMbps);
        return _offerCounter;
    }

    function createRequest(
        uint256 bandwidthMbps,
        uint256 maxBudget,
        uint256 requestedFrom,
        uint256 requestedUntil,
        string calldata zone
    ) external returns (uint256) {
        _requestCounter++;
        requests[_requestCounter] = Request({
            id: _requestCounter,
            operator: msg.sender,
            bandwidthMbps: bandwidthMbps,
            maxBudget: maxBudget,
            requestedFrom: requestedFrom,
            requestedUntil: requestedUntil,
            zone: zone,
            isOpen: true
        });
        emit RequestCreated(_requestCounter, msg.sender, bandwidthMbps);
        return _requestCounter;
    }

    function recordMatch(
        uint256 offerId,
        uint256 requestId,
        uint256 score,
        uint256 allocatedBandwidth,
        uint256 totalPrice,
        uint256 scheduleFrom,
        uint256 scheduleUntil
    ) external onlyRole(OPERATOR_ROLE) returns (uint256) {
        require(offers[offerId].isActive, "Offer not active");
        require(requests[requestId].isOpen, "Request not open");

        _matchCounter++;
        matches[_matchCounter] = Match({
            id: _matchCounter,
            offerId: offerId,
            requestId: requestId,
            score: score,
            allocatedBandwidth: allocatedBandwidth,
            totalPrice: totalPrice,
            scheduleFrom: scheduleFrom,
            scheduleUntil: scheduleUntil
        });

        offers[offerId].isActive = false;
        requests[requestId].isOpen = false;

        emit MatchCreated(_matchCounter, offerId, requestId, totalPrice);
        return _matchCounter;
    }
}
