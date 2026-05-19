# ✈️ AeroTrack

**AeroTrack** is a blockchain-based aerospace parts tracking system built on Ethereum using Solidity. It enables transparent, tamper-proof lifecycle management of aircraft components — from manufacturing through installation and retirement — ensuring regulatory compliance and full chain-of-custody visibility.

---

## 📋 Overview

Aircraft part traceability is a critical safety requirement in the aerospace industry. AeroTrack addresses this by recording every part's origin, ownership history, and maintenance events directly on-chain, making records immutable, auditable, and trustless.

---

## 🚀 Features

- **Manufacturer Verification** — The regulatory authority can verify and whitelist manufacturer addresses before they are permitted to register parts.
- **Part Registration** — Verified manufacturers can register new parts with a unique serial number on-chain.
- **Ownership Transfers** — Parts can be securely transferred between parties, with full history preserved via events.
- **Maintenance Logging** — Mechanics/owners can log maintenance reports tied to specific parts.
- **Status Lifecycle Tracking** — Each part moves through defined statuses: `Manufactured → InTransit → Installed → Retired`.
- **Regulatory Authority Role** — A designated authority address is set at deployment for governance purposes.
- **Access Control** — Functions are protected by ownership and authority modifiers to prevent unauthorized actions.

---

## 🔧 Contract Details

- **Solidity Version:** `^0.8.19`
- **Contract Name:** `AeroTrack`
- **Network:** Compatible with any EVM-based blockchain (Ethereum, Polygon, etc.)

---

## 📦 Data Structures

### `PartStatus` (Enum)
Represents the current lifecycle stage of a part.

| Value | Description |
|-------|-------------|
| `Manufactured` | Part has just been created and registered |
| `InTransit` | Part is being transferred to a new owner |
| `Installed` | Part has been installed after maintenance |
| `Retired` | Part has been taken out of service |

### `Part` (Struct)

| Field | Type | Description |
|-------|------|-------------|
| `serialNumber` | `uint256` | Unique identifier for the part |
| `partName` | `string` | Human-readable name of the part |
| `manufacturer` | `address` | Wallet address of the original manufacturer |
| `currentOwner` | `address` | Wallet address of the current owner |
| `status` | `PartStatus` | Current lifecycle status |
| `exists` | `bool` | Guards against duplicate registration |

### `ManufacturerIdentity` (Struct)

| Field | Type | Description |
|-------|------|-------------|
| `companyName` | `string` | Human-readable name of the manufacturer company |
| `isVerified` | `bool` | Whether the manufacturer has been approved by the regulatory authority |

---

## 📡 Events

| Event | Trigger | Parameters |
|-------|---------|------------|
| `PartManufactured` | A new part is registered | `serialNumber`, `partName`, `manufacturer` |
| `OwnershipTransferred` | A part changes hands | `serialNumber`, `oldOwner`, `newOwner` |
| `MaintenanceLogged` | A maintenance report is submitted | `serialNumber`, `mechanic`, `report` |
| `ManufacturerVerified` | A manufacturer address is approved by the authority | `manufacturerAddress`, `companyName` |

---

## 🔐 Access Control

### Modifiers

| Modifier | Description |
|----------|-------------|
| `onlyAuthority` | Restricts access to the `regulatoryAuthority` address |
| `onlyVerifiedManufacturer` | Reverts if the caller has not been verified by the regulatory authority |
| `partExists(serialNumber)` | Reverts if the part is not registered |
| `onlyPartOwner(serialNumber)` | Reverts if the caller is not the current owner of the part |

---

## ⚙️ Functions

### `verifyManufacturer(address _manufacturer, string memory _companyName)`
Approves a manufacturer address, allowing it to register parts on-chain.
- Restricted to the regulatory authority (`onlyAuthority`).
- Stores the manufacturer's company name and sets `isVerified` to `true`.
- Emits a `ManufacturerVerified` event.

### `manufacturePart(uint256 _serialNumber, string memory _partName)`
Registers a new part on-chain.
- Restricted to verified manufacturers (`onlyVerifiedManufacturer`).
- Caller becomes both the `manufacturer` and `currentOwner`.
- Reverts if the serial number is already registered.
- Sets initial status to `Manufactured`.

### `transferPart(uint256 _serialNumber, address _newOwner)`
Transfers ownership of a part to a new address.
- Restricted to the current owner (`onlyPartOwner`).
- Reverts if transferring to the zero address.
- Updates status to `InTransit`.

### `logMaintenance(uint256 _serialNumber, string memory _report)`
Logs a maintenance event for a part.
- Restricted to the current owner (`onlyPartOwner`).
- Emits a `MaintenanceLogged` event with the report string.
- Updates status to `Installed`.

---

## 🏗️ Deployment

### Constructor
```solidity
constructor()
```
- Sets `regulatoryAuthority` to the deploying wallet address (`msg.sender`).
- No constructor arguments required.

### Steps
1. Compile the contract with a Solidity compiler `^0.8.19`.
2. Deploy using Hardhat, Foundry, or Remix IDE.
3. The deploying address automatically becomes the `regulatoryAuthority`.
4. The authority must call `verifyManufacturer` to whitelist addresses before any parts can be registered.

---

## 💡 Usage Example

```solidity
// 1. Regulatory authority verifies a manufacturer
aeroTrack.verifyManufacturer(0xManufacturerAddress, "AeroCorp Inc.");

// 2. Verified manufacturer registers a new part
aeroTrack.manufacturePart(100123, "Turbine Blade A7");

// 3. Manufacturer ships the part to a maintenance facility
aeroTrack.transferPart(100123, 0xMaintenanceFacilityAddress);

// 4. Maintenance facility logs an inspection report
aeroTrack.logMaintenance(100123, "Blade inspected. No cracks. Cleared for installation.");
```

---

## 🛡️ Security Considerations

- **Manufacturer Gating:** Only addresses explicitly approved by the regulatory authority can register parts, preventing rogue or unverified actors from polluting the registry.
- **Duplicate Serial Numbers:** Prevented by the `exists` flag checked on registration.
- **Zero Address Transfers:** Explicitly blocked in `transferPart`.
- **Unauthorized Access:** Ownership and authority checks are enforced via modifiers on all state-changing functions.
- **Immutable History:** All key actions emit on-chain events that cannot be altered retroactively.