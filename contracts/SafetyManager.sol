// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ErrorHandler.sol";

/**
 * @title SafetyManager
 * @notice Safety mechanisms, access control, and emergency functions
 * @dev Pausable, access control, rate limiting, circuit breakers
 */
contract SafetyManager is ErrorHandler {
    // ==================== STATE VARIABLES ====================

    /// @notice Contract owner
    address public owner;

    /// @notice Admins with elevated privileges
    mapping(address => bool) public isAdmin;

    /// @notice Paused state
    bool public paused;

    /// @notice Emergency stop
    bool public emergencyStop;

    /// @notice Rate limiting
    mapping(address => mapping(bytes4 => uint256)) public lastCall;
    mapping(bytes4 => uint256) public cooldownPeriod;

    /// @notice Spending limits
    mapping(address => uint256) public dailySpent;
    mapping(address => uint256) public lastResetTime;
    uint256 public dailySpendLimit = 1000 ether;

    /// @notice Circuit breaker
    uint256 public failureCount;
    uint256 public constant MAX_FAILURES = 10;
    uint256 public lastFailureTime;

    // ==================== EVENTS ====================

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );

    event AdminAdded(
        address indexed admin,
        address indexed addedBy,
        uint256 timestamp
    );

    event AdminRemoved(
        address indexed admin,
        address indexed removedBy,
        uint256 timestamp
    );

    event Paused(
        address indexed by,
        string reason,
        uint256 timestamp
    );

    event Unpaused(
        address indexed by,
        uint256 timestamp
    );

    event EmergencyStopActivated(
        address indexed by,
        string reason,
        uint256 timestamp
    );

    event EmergencyStopDeactivated(
        address indexed by,
        uint256 timestamp
    );

    event RateLimitExceeded(
        address indexed caller,
        bytes4 indexed functionSig,
        uint256 cooldown,
        uint256 timestamp
    );

    event SpendLimitExceeded(
        address indexed spender,
        uint256 amount,
        uint256 limit,
        uint256 timestamp
    );

    event CircuitBreakerTriggered(
        uint256 failureCount,
        uint256 timestamp
    );

    event FundsRecovered(
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    // ==================== MODIFIERS ====================

    /**
     * @notice Only owner can call
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            _logAccessDenied(msg.sender, "owner", "onlyOwner");
            revert NotOwner(msg.sender, owner);
        }
        _;
    }

    /**
     * @notice Only admin can call
     */
    modifier onlyAdmin() {
        if (!isAdmin[msg.sender] && msg.sender != owner) {
            _logAccessDenied(msg.sender, "admin", "onlyAdmin");
            revert Unauthorized(msg.sender, "Not an admin");
        }
        _;
    }

    /**
     * @notice Only when not paused
     */
    modifier whenNotPaused() {
        if (paused) {
            _logError("PauseError", msg.sender, bytes32(0), "Contract is paused");
            revert ContractPaused();
        }
        _;
    }

    /**
     * @notice Only when paused
     */
    modifier whenPaused() {
        if (!paused) {
            revert NotPaused();
        }
        _;
    }

    /**
     * @notice Only when emergency stop not activated
     */
    modifier whenNotStopped() {
        if (emergencyStop) {
            _logEmergency("EmergencyStopActive", msg.sender, "Operation blocked");
            revert InvalidState("running", "stopped");
        }
        _;
    }

    /**
     * @notice Rate limiting
     */
    modifier rateLimit(bytes4 functionSig) {
        uint256 cooldown = cooldownPeriod[functionSig];
        if (cooldown > 0) {
            uint256 timeSinceLastCall = block.timestamp - lastCall[msg.sender][functionSig];
            if (timeSinceLastCall < cooldown) {
                emit RateLimitExceeded(msg.sender, functionSig, cooldown - timeSinceLastCall, block.timestamp);
                revert PowerOnCooldown(msg.sender, "function", cooldown - timeSinceLastCall);
            }
            lastCall[msg.sender][functionSig] = block.timestamp;
        }
        _;
    }

    /**
     * @notice Spending limit check
     */
    modifier checkSpendLimit(uint256 amount) {
        _resetDailySpendIfNeeded(msg.sender);

        if (dailySpent[msg.sender] + amount > dailySpendLimit) {
            emit SpendLimitExceeded(msg.sender, amount, dailySpendLimit, block.timestamp);
            revert OutOfBounds(dailySpent[msg.sender] + amount, 0, dailySpendLimit);
        }

        dailySpent[msg.sender] += amount;
        _;
    }

    // ==================== CONSTRUCTOR ====================

    constructor() {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
        emit OwnershipTransferred(address(0), msg.sender, block.timestamp);
        emit AdminAdded(msg.sender, msg.sender, block.timestamp);
    }

    // ==================== ACCESS CONTROL ====================

    /**
     * @notice Transfer ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert InvalidAddress(newOwner);
        }

        address oldOwner = owner;
        owner = newOwner;
        isAdmin[newOwner] = true;

        emit OwnershipTransferred(oldOwner, newOwner, block.timestamp);
    }

    /**
     * @notice Add admin
     */
    function addAdmin(address admin) external onlyOwner {
        if (admin == address(0)) {
            revert InvalidAddress(admin);
        }
        if (isAdmin[admin]) {
            revert AlreadyGod(admin);
        }

        isAdmin[admin] = true;
        emit AdminAdded(admin, msg.sender, block.timestamp);
    }

    /**
     * @notice Remove admin
     */
    function removeAdmin(address admin) external onlyOwner {
        if (admin == owner) {
            revert Unauthorized(msg.sender, "Cannot remove owner as admin");
        }

        isAdmin[admin] = false;
        emit AdminRemoved(admin, msg.sender, block.timestamp);
    }

    // ==================== PAUSE FUNCTIONALITY ====================

    /**
     * @notice Pause contract
     */
    function pause(string memory reason) external onlyAdmin {
        if (paused) {
            revert AlreadyPaused();
        }

        paused = true;
        emit Paused(msg.sender, reason, block.timestamp);
        _logEmergency("Pause", msg.sender, reason);
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyAdmin {
        if (!paused) {
            revert NotPaused();
        }

        paused = false;
        emit Unpaused(msg.sender, block.timestamp);
    }

    /**
     * @notice Emergency stop (more severe than pause)
     */
    function activateEmergencyStop(string memory reason) external onlyOwner {
        emergencyStop = true;
        paused = true;

        emit EmergencyStopActivated(msg.sender, reason, block.timestamp);
        _logEmergency("EmergencyStop", msg.sender, reason);
    }

    /**
     * @notice Deactivate emergency stop
     */
    function deactivateEmergencyStop() external onlyOwner {
        emergencyStop = false;

        emit EmergencyStopDeactivated(msg.sender, block.timestamp);
    }

    // ==================== RATE LIMITING ====================

    /**
     * @notice Set cooldown period for function
     */
    function setCooldown(bytes4 functionSig, uint256 period) external onlyAdmin {
        cooldownPeriod[functionSig] = period;
    }

    /**
     * @notice Set daily spend limit
     */
    function setDailySpendLimit(uint256 limit) external onlyOwner {
        dailySpendLimit = limit;
    }

    /**
     * @notice Reset daily spend tracking
     */
    function _resetDailySpendIfNeeded(address user) private {
        if (block.timestamp >= lastResetTime[user] + 1 days) {
            dailySpent[user] = 0;
            lastResetTime[user] = block.timestamp;
        }
    }

    // ==================== CIRCUIT BREAKER ====================

    /**
     * @notice Record failure
     */
    function _recordFailure() internal {
        failureCount++;
        lastFailureTime = block.timestamp;

        if (failureCount >= MAX_FAILURES) {
            paused = true;
            emit CircuitBreakerTriggered(failureCount, block.timestamp);
            _logEmergency("CircuitBreaker", address(this), "Too many failures");
        }
    }

    /**
     * @notice Reset failure count
     */
    function resetFailureCount() external onlyAdmin {
        failureCount = 0;
    }

    // ==================== EMERGENCY FUNCTIONS ====================

    /**
     * @notice Recover stuck funds
     */
    function recoverFunds(address payable to, uint256 amount) external onlyOwner {
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        if (amount > address(this).balance) {
            revert InsufficientResources(address(this).balance, amount);
        }

        (bool success, ) = to.call{value: amount}("");
        if (!success) {
            revert PaymentFailed(to, amount);
        }

        emit FundsRecovered(to, amount, block.timestamp);
    }

    /**
     * @notice Get contract balance
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ==================== FALLBACK ====================

    /**
     * @notice Receive ETH
     */
    receive() external payable {
        // Accept ETH payments
    }

    /**
     * @notice Fallback function
     */
    fallback() external payable {
        _logError("FallbackCalled", msg.sender, bytes32(msg.sig), "Unknown function called");
        revert InvalidParameter("function", "Function does not exist");
    }
}
