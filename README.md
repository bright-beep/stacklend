# StackLend: Decentralized Lending Protocol

StackLend is a decentralized lending protocol built on the Stacks blockchain that enables secure, transparent, and efficient lending operations using STX tokens as collateral.

## Overview

StackLend allows users to:

- Deposit STX tokens as collateral
- Borrow against their collateral
- Repay loans
- Withdraw collateral
- Participate in liquidations

The protocol implements dynamic interest rates, collateralization ratios, and liquidation mechanisms to maintain system stability and protect users.

## Key Features

### Collateralization and Borrowing

- Minimum collateralization ratio: 150%
- Maximum collateralization ratio: 500%
- Liquidation threshold: 130%
- Protocol fee: 1% (configurable up to 10%)

### Core Functions

#### For Users

1. **Deposit (`deposit`)**

   - Allows users to deposit STX tokens as collateral
   - Updates total deposits and user position
   - Returns the deposited amount

2. **Borrow (`borrow`)**

   - Enables borrowing against deposited collateral
   - Requires maintaining minimum collateralization ratio
   - Updates total borrows and user position
   - Returns borrowed amount

3. **Repay (`repay`)**

   - Allows users to repay borrowed amounts
   - Updates total borrows and user position
   - Returns repaid amount

4. **Withdraw (`withdraw`)**
   - Enables withdrawal of collateral
   - Ensures remaining position maintains minimum collateralization
   - Updates total deposits and user position
   - Returns withdrawn amount

#### For Liquidators

**Liquidate (`liquidate`)**

- Allows liquidation of under-collateralized positions
- Triggers when position falls below liquidation threshold (130%)
- Transfers collateral to liquidator
- Clears user position

#### Read-Only Functions

1. **Get User Position (`get-user-position`)**

   ```clarity
   {
     total-collateral: uint,
     total-borrowed: uint,
     loan-count: uint
   }
   ```

2. **Get Protocol Stats (`get-protocol-stats`)**
   ```clarity
   {
     total-deposits: uint,
     total-borrows: uint,
     minimum-collateral-ratio: uint,
     liquidation-threshold: uint,
     protocol-fee: uint
   }
   ```

### Administrative Controls

Contract owner can adjust key parameters within defined bounds:

1. **Set Minimum Collateral Ratio (`set-minimum-collateral-ratio`)**

   - Range: 110% to 500%
   - Must be higher than liquidation threshold

2. **Set Liquidation Threshold (`set-liquidation-threshold`)**

   - Must be between minimum collateral ratio (110%) and current minimum collateral ratio
   - Default: 130%

3. **Set Protocol Fee (`set-protocol-fee`)**
   - Maximum: 10%
   - Default: 1%

## Error Codes

| Code | Description             |
| ---- | ----------------------- |
| u100 | Not authorized          |
| u101 | Insufficient collateral |
| u102 | Invalid amount          |
| u103 | Loan not found          |
| u104 | Loan active             |
| u105 | Insufficient balance    |
| u106 | Liquidation failed      |
| u107 | Invalid parameter       |

## Security Features

1. **Access Control**

   - Administrative functions restricted to contract owner
   - Self-liquidation prevention
   - Secure parameter bounds

2. **Position Management**

   - Dynamic collateral ratio tracking
   - Safe position updates
   - Protected withdrawal conditions

3. **System Stability**
   - Minimum collateralization requirements
   - Liquidation mechanisms
   - Fee structure for sustainability

## Interest Calculation

Interest is calculated using the following formula:

```clarity
interest-per-block = (principal * rate) / 10000
total-interest = interest-per-block * blocks
```

## Usage Examples

### Depositing Collateral

```clarity
;; Deposit STX tokens
(contract-call? .stacklend deposit)
```

### Borrowing Against Collateral

```clarity
;; Borrow 100 STX
(contract-call? .stacklend borrow u100)
```

### Repaying a Loan

```clarity
;; Repay 50 STX
(contract-call? .stacklend repay u50)
```

### Withdrawing Collateral

```clarity
;; Withdraw 75 STX
(contract-call? .stacklend withdraw u75)
```

## Best Practices

1. **For Users**

   - Maintain healthy collateralization ratios (>150%)
   - Monitor market conditions
   - Repay loans promptly to avoid liquidation

2. **For Liquidators**

   - Monitor positions near liquidation threshold
   - Ensure sufficient STX balance for liquidation
   - Understand liquidation penalties and rewards

3. **For Administrators**
   - Regular monitoring of system parameters
   - Gradual parameter adjustments
   - Emergency response planning

## Technical Considerations

1. **Block Height**

   - Used for interest calculations
   - Timestamp approximation
   - Loan duration tracking

2. **Position Updates**

   - Atomic operations
   - Safe state transitions
   - Balance verification

3. **Error Handling**
   - Comprehensive error codes
   - Clear error messages
   - Safe state rollback

## Contributing

We welcome contributions to StackLend! Please ensure:

1. Comprehensive testing of changes
2. Clear documentation updates
3. Adherence to Clarity best practices
4. Security-first approach
