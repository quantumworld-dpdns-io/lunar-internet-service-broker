// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RelayRegistry is AccessControl {
    bytes32 public constant PROVIDER_ROLE = keccak256("PROVIDER_ROLE");

    struct RelayInfo {
        uint256 id;
        address provider;
        string name;
        uint256 totalBandwidthMbps;
        string coverageZone;
        uint256 altitudeKm;
        bool isRegistered;
    }

    struct RoverInfo {
        uint256 id;
        address operator;
        string name;
        uint256 requiredBandwidthMbps;
        string zone;
        bool isRegistered;
    }

    uint256 private _relayCounter;
    uint256 private _roverCounter;

    mapping(uint256 => RelayInfo) public relays;
    mapping(uint256 => RoverInfo) public rovers;

    event RelayRegistered(uint256 indexed id, address indexed provider, string name);
    event RoverRegistered(uint256 indexed id, address indexed operator, string name);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerRelay(
        string calldata name,
        uint256 totalBandwidthMbps,
        string calldata coverageZone,
        uint256 altitudeKm
    ) external returns (uint256) {
        _relayCounter++;
        relays[_relayCounter] = RelayInfo({
            id: _relayCounter,
            provider: msg.sender,
            name: name,
            totalBandwidthMbps: totalBandwidthMbps,
            coverageZone: coverageZone,
            altitudeKm: altitudeKm,
            isRegistered: true
        });
        _grantRole(PROVIDER_ROLE, msg.sender);
        emit RelayRegistered(_relayCounter, msg.sender, name);
        return _relayCounter;
    }

    function registerRover(
        string calldata name,
        uint256 requiredBandwidthMbps,
        string calldata zone
    ) external returns (uint256) {
        _roverCounter++;
        rovers[_roverCounter] = RoverInfo({
            id: _roverCounter,
            operator: msg.sender,
            name: name,
            requiredBandwidthMbps: requiredBandwidthMbps,
            zone: zone,
            isRegistered: true
        });
        emit RoverRegistered(_roverCounter, msg.sender, name);
        return _roverCounter;
    }

    function getRelay(uint256 id) external view returns (RelayInfo memory) {
        require(relays[id].isRegistered, "Relay not found");
        return relays[id];
    }

    function getRover(uint256 id) external view returns (RoverInfo memory) {
        require(rovers[id].isRegistered, "Rover not found");
        return rovers[id];
    }
}
