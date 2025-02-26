# BioNFT Smart Contract

## Overview

BioNFT is a smart contract built for the Stacks blockchain that enables the minting, transfer, and management of NFTs (Non-Fungible Tokens) representing biological assets and data. This contract is designed specifically for biotech-related applications, allowing for unique digital ownership of biological specimens, gene sequences, protein structures, and other biological data.

## Features

- Mint NFTs with comprehensive biological classification data
- Store detailed biometric information including gene sequences and protein structures
- Manage metadata with options to update or freeze information
- Transfer ownership of biological digital assets
- Burn NFTs to remove them from circulation
- Admin controls for contract management

## Data Structure

Each BioNFT contains three main categories of data:

### Core NFT Data
- Owner and creator information
- Metadata URI for off-chain data storage
- Data hash for verification
- Timestamps for creation and modification
- Metadata freeze status
- Royalty percentage

### Biological Classification
- Full taxonomic classification including:
  - Domain
  - Kingdom
  - Phylum
  - Class
  - Order
  - Family
  - Genus
  - Species

### Biometric Data
- Gene sequence (up to 1024 characters)
- Molecular weight
- Protein structure information
- Isolation date
- Laboratory certification details

## Functions

### Read-Only Functions

- `getOwner`: Returns the owner of a specific NFT
- `getLastTokenId`: Returns the ID of the last minted NFT
- `getTokenUri`: Returns the metadata URI for a specific NFT
- `getBioClassification`: Returns the taxonomic classification data for a specific NFT
- `getBioMetrics`: Returns the biometric data for a specific NFT

### Public Functions

- `mint`: Creates a new BioNFT with complete biological and biometric data
- `transfer`: Transfers ownership of an NFT to another principal
- `updateMetadata`: Updates the metadata URI (if not frozen)
- `updateBioClassification`: Updates the taxonomic classification data
- `updateBioMetrics`: Updates the biometric data
- `freezeMetadata`: Permanently locks the metadata URI
- `burn`: Destroys an NFT and removes all associated data

### Administrative Functions

- `setContractOwner`: Transfers contract ownership to a new principal
- `toggleContractPause`: Pauses or unpauses the contract functionality

## Error Codes

- `ERR_NOT_AUTHORIZED (u100)`: User not authorized for action
- `ERR_NFT_ALREADY_EXISTS (u101)`: NFT ID already exists
- `ERR_NFT_DOES_NOT_EXIST (u102)`: NFT does not exist
- `ERR_NOT_NFT_OWNER (u103)`: User is not the NFT owner
- `ERR_METADATA_FROZEN (u104)`: Metadata is frozen and cannot be modified
- `ERR_INVALID_TIMESTAMP (u105)`: Invalid timestamp
- `ERR_INVALID_DATA_HASH (u106)`: Invalid data hash format or length
- `ERR_ROYALTY_CONSTRAINTS (u107)`: Royalty percentage exceeds limits
- `ERR_INVALID_INPUT (u108)`: Invalid input parameters
- `ERR_EMPTY_STRING (u109)`: Empty string provided
- `ERR_INVALID_MOLECULAR_WEIGHT (u110)`: Invalid molecular weight value
- `ERR_INVALID_DATE (u111)`: Invalid date value

## Usage Example

### Minting a New BioNFT

```clarity
(contract-call? .bionft mint 
  u"https://example.com/metadata/123" 
  0x8c1e21ac4adacb0a2b57ce00956b4a2fb30c16cb7a0e5bc2f1ec4a17f0a2f920
  u5
  u"Eukaryota" 
  u"Animalia" 
  u"Chordata" 
  u"Mammalia" 
  u"Primates" 
  u"Hominidae" 
  u"Homo" 
  u"Homo sapiens"
  u"ATGCGTAGCTAGCTACGTAGCTAGCTAGCTAGCTAGCTAGCTAGC"
  u120000
  u"Alpha helix structure with beta sheets"
  u1672531200
  u"Certified by BioLab Inc. #CRT-2023-01-15")
```

### Transferring a BioNFT

```clarity
(contract-call? .bionft transfer u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Updating Biometric Data

```clarity
(contract-call? .bionft updateBioMetrics u1
  u"ATGCGTAGCTAGCTACGTAGCTAGCTAGCTAGCTAGCTAGCTAGC"
  u125000
  u"Updated protein structure with new findings"
  u1672531200
  u"Re-certified by BioLab Inc. #CRT-2023-02-20")
```

## Implementation Considerations

- The contract includes validation functions to ensure data integrity
- String length limits are enforced to optimize storage efficiency
- Timestamps are validated against block height
- Molecular weights must be positive numbers
- All taxonomic classification fields are required
- Laboratory certification data should include reference numbers and dates