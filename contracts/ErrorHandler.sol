// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ErrorHandler
 * @notice Centralized error definitions and logging
 * @dev Custom errors for gas efficiency and better error messages
 */
contract ErrorHandler {
    // ==================== CUSTOM ERRORS ====================
    // Gas efficient error definitions

    /// @notice Access control errors
    error Unauthorized(address caller, string reason);
    error NotOwner(address caller, address owner);
    error NotGod(address caller);
    error AlreadyGod(address account);

    /// @notice Payment errors
    error InsufficientPayment(uint256 required, uint256 provided);
    error PaymentFailed(address recipient, uint256 amount);
    error RefundFailed(address recipient, uint256 amount);

    /// @notice State errors
    error ContractPaused();
    error AlreadyPaused();
    error NotPaused();
    error InvalidState(string expected, string actual);

    /// @notice Validation errors
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);
    error InvalidParameter(string parameter, string reason);
    error ArrayLengthMismatch(uint256 length1, uint256 length2);
    error OutOfBounds(uint256 value, uint256 min, uint256 max);

    /// @notice Organism errors
    error OrganismNotFound(address organism);
    error OrganismDead(address organism);
    error OrganismTooYoung(address organism, uint256 age, uint256 required);
    error InsufficientEnergy(address organism, uint256 current, uint256 required);

    /// @notice Marketplace errors
    error ListingNotFound(bytes32 listingId);
    error ListingExpired(bytes32 listingId);
    error ListingNotActive(bytes32 listingId);
    error AlreadySold(bytes32 listingId);
    error NotSeller(address caller, address seller);
    error BidTooLow(uint256 bid, uint256 minimum);
    error AuctionNotEnded(bytes32 auctionId, uint256 endTime);
    error AuctionAlreadyEnded(bytes32 auctionId);

    /// @notice Breeding errors
    error BreedingFailed(address parent1, address parent2, string reason);
    error IncompatibleGenetics(address parent1, address parent2);
    error CRISPRFailed(address organism, bytes32 geneId);
    error CloneFailed(address original);
    error MutationFailed(address organism);

    /// @notice God mode errors
    error PowerOnCooldown(address god, string power, uint256 remainingTime);
    error CatastropheTooSevere(uint256 severity, uint256 max);
    error InvalidTimeAcceleration(uint256 factor, uint256 max);
    error RealityWarpFailed(string parameter);

    /// @notice Resource errors
    error InsufficientResources(uint256 available, uint256 required);
    error ResourcePoolEmpty();
    error ResourceTransferFailed();

    /// @notice Project errors
    error ProjectNotFound(bytes32 projectId);
    error ProjectNotActive(bytes32 projectId);
    error InsufficientBudget(bytes32 projectId, uint256 budget, uint256 required);

    // ==================== ERROR LOGGING EVENTS ====================

    /// @notice Log all errors for debugging and monitoring
    event ErrorLogged(
        string errorType,
        address indexed caller,
        bytes32 indexed identifier,
        string message,
        uint256 timestamp
    );

    event AccessDenied(
        address indexed caller,
        string requiredRole,
        string action,
        uint256 timestamp
    );

    event PaymentError(
        address indexed from,
        address indexed to,
        uint256 amount,
        string reason,
        uint256 timestamp
    );

    event OperationFailed(
        string operation,
        address indexed target,
        bytes32 indexed identifier,
        string reason,
        uint256 timestamp
    );

    event ValidationFailed(
        string parameter,
        uint256 value,
        string constraint,
        uint256 timestamp
    );

    event EmergencyEvent(
        string eventType,
        address indexed triggeredBy,
        string reason,
        uint256 timestamp
    );

    // ==================== ERROR LOGGING FUNCTIONS ====================

    /**
     * @notice Log generic error
     */
    function _logError(
        string memory errorType,
        address caller,
        bytes32 identifier,
        string memory message
    ) internal {
        emit ErrorLogged(errorType, caller, identifier, message, block.timestamp);
    }

    /**
     * @notice Log access denied
     */
    function _logAccessDenied(
        address caller,
        string memory requiredRole,
        string memory action
    ) internal {
        emit AccessDenied(caller, requiredRole, action, block.timestamp);
    }

    /**
     * @notice Log payment error
     */
    function _logPaymentError(
        address from,
        address to,
        uint256 amount,
        string memory reason
    ) internal {
        emit PaymentError(from, to, amount, reason, block.timestamp);
    }

    /**
     * @notice Log operation failure
     */
    function _logOperationFailed(
        string memory operation,
        address target,
        bytes32 identifier,
        string memory reason
    ) internal {
        emit OperationFailed(operation, target, identifier, reason, block.timestamp);
    }

    /**
     * @notice Log validation failure
     */
    function _logValidationFailed(
        string memory parameter,
        uint256 value,
        string memory constraint
    ) internal {
        emit ValidationFailed(parameter, value, constraint, block.timestamp);
    }

    /**
     * @notice Log emergency event
     */
    function _logEmergency(
        string memory eventType,
        address triggeredBy,
        string memory reason
    ) internal {
        emit EmergencyEvent(eventType, triggeredBy, reason, block.timestamp);
    }
}
