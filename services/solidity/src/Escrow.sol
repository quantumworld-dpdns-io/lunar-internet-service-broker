// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./LunarRelayToken.sol";

contract Escrow is AccessControl, ReentrancyGuard {
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");

    LunarRelayToken public relayToken;

    enum EscrowStatus { Held, Released, Refunded, Disputed }

    struct EscrowAccount {
        uint256 id;
        uint256 matchId;
        address depositor;
        address beneficiary;
        uint256 amount;
        EscrowStatus status;
        uint256 createdAt;
    }

    uint256 private _escrowCounter;
    mapping(uint256 => EscrowAccount) public escrows;
    mapping(uint256 => uint256) public matchEscrows;

    event EscrowCreated(uint256 indexed id, uint256 indexed matchId, address depositor, uint256 amount);
    event EscrowReleased(uint256 indexed id, address beneficiary, uint256 amount);
    event EscrowRefunded(uint256 indexed id, address depositor, uint256 amount);
    event DisputeOpened(uint256 indexed id);
    event DisputeResolved(uint256 indexed id, bool releaseToBeneficiary);

    constructor(address tokenAddress) {
        relayToken = LunarRelayToken(tokenAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ARBITRATOR_ROLE, msg.sender);
    }

    function createEscrow(
        uint256 matchId,
        address beneficiary,
        uint256 amount
    ) external nonReentrant returns (uint256) {
        require(amount > 0, "Amount must be > 0");
        require(relayToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        _escrowCounter++;
        escrows[_escrowCounter] = EscrowAccount({
            id: _escrowCounter,
            matchId: matchId,
            depositor: msg.sender,
            beneficiary: beneficiary,
            amount: amount,
            status: EscrowStatus.Held,
            createdAt: block.timestamp
        });
        matchEscrows[matchId] = _escrowCounter;

        emit EscrowCreated(_escrowCounter, matchId, msg.sender, amount);
        return _escrowCounter;
    }

    function release(uint256 escrowId) external nonReentrant {
        EscrowAccount storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Held, "Not in held state");
        require(msg.sender == escrow.depositor || hasRole(ARBITRATOR_ROLE, msg.sender), "Not authorized");

        escrow.status = EscrowStatus.Released;
        require(relayToken.transfer(escrow.beneficiary, escrow.amount), "Transfer failed");

        emit EscrowReleased(escrowId, escrow.beneficiary, escrow.amount);
    }

    function refund(uint256 escrowId) external nonReentrant {
        EscrowAccount storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Held || escrow.status == EscrowStatus.Disputed, "Not refundable");
        require(msg.sender == escrow.depositor || hasRole(ARBITRATOR_ROLE, msg.sender), "Not authorized");

        escrow.status = EscrowStatus.Refunded;
        require(relayToken.transfer(escrow.depositor, escrow.amount), "Transfer failed");

        emit EscrowRefunded(escrowId, escrow.depositor, escrow.amount);
    }

    function openDispute(uint256 escrowId) external {
        EscrowAccount storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Held, "Not in held state");
        require(msg.sender == escrow.depositor || msg.sender == escrow.beneficiary, "Not party to escrow");

        escrow.status = EscrowStatus.Disputed;
        emit DisputeOpened(escrowId);
    }

    function resolveDispute(uint256 escrowId, bool releaseToBeneficiary) external onlyRole(ARBITRATOR_ROLE) {
        EscrowAccount storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Disputed, "Not in disputed state");

        if (releaseToBeneficiary) {
            escrow.status = EscrowStatus.Released;
            require(relayToken.transfer(escrow.beneficiary, escrow.amount), "Transfer failed");
        } else {
            escrow.status = EscrowStatus.Refunded;
            require(relayToken.transfer(escrow.depositor, escrow.amount), "Transfer failed");
        }

        emit DisputeResolved(escrowId, releaseToBeneficiary);
    }
}
