;; BioNFT: A smart contract for biotech-related NFTs
;; This allows for unique digital ownership of biological data and assets

(define-non-fungible-token bioNft uint)

;; Error codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_NFT_ALREADY_EXISTS (err u101))
(define-constant ERR_NFT_DOES_NOT_EXIST (err u102))
(define-constant ERR_NOT_NFT_OWNER (err u103))
(define-constant ERR_METADATA_FROZEN (err u104))
(define-constant ERR_INVALID_TIMESTAMP (err u105))
(define-constant ERR_INVALID_DATA_HASH (err u106))
(define-constant ERR_ROYALTY_CONSTRAINTS (err u107))
(define-constant ERR_INVALID_INPUT (err u108))
(define-constant ERR_EMPTY_STRING (err u109))
(define-constant ERR_INVALID_MOLECULAR_WEIGHT (err u110))
(define-constant ERR_INVALID_DATE (err u111))

;; Data maps for storing NFT information
(define-map bioNftData
  uint
  {
    owner: principal,
    creator: principal,
    metadataUri: (string-utf8 256),
    dataHash: (buff 32),
    creationTimestamp: uint,
    lastModified: uint,
    isMetadataFrozen: bool,
    royaltyPercentage: uint
  }
)

;; Map to store biological classification data
(define-map bioClassificationData
  uint
  {
    domain: (string-utf8 64),
    kingdom: (string-utf8 64),
    phylum: (string-utf8 64),
    class: (string-utf8 64),
    order: (string-utf8 64),
    family: (string-utf8 64),
    genus: (string-utf8 64),
    species: (string-utf8 64)
  }
)

;; Map to store biometric data for the NFT
(define-map bioMetricData
  uint
  {
    geneSequence: (string-utf8 1024),
    molecularWeight: uint,
    proteinStructure: (string-utf8 512),
    isolationDate: uint,
    labCertification: (string-utf8 256)
  }
)

;; Contract variables
(define-data-var lastNftId uint u0)
(define-data-var contractOwner principal tx-sender)
(define-data-var contractPaused bool false)

;; Validation functions
(define-private (validate-non-empty-string-256 (input (string-utf8 256)))
  (not (is-eq input u""))
)

(define-private (validate-non-empty-string-64 (input (string-utf8 64)))
  (not (is-eq input u""))
)

(define-private (validate-non-empty-string-512 (input (string-utf8 512)))
  (not (is-eq input u""))
)

(define-private (validate-non-empty-string-1024 (input (string-utf8 1024)))
  (not (is-eq input u""))
)

(define-private (validate-metadata-uri (uri (string-utf8 256)))
  (validate-non-empty-string-256 uri)
)

(define-private (validate-taxonomy-string (input (string-utf8 64)))
  (validate-non-empty-string-64 input)
)

(define-private (validate-molecular-weight (weight uint))
  (> weight u0)
)

(define-private (validate-date (date uint))
  (and
    (> date u0)
    (<= date (default-to u0 (get-block-info? time (- block-height u1))))
  )
)

(define-private (validate-principal (principal-to-check principal))
  (not (is-eq principal-to-check tx-sender))
)

;; Read-only functions
(define-read-only (getOwner (nftId uint))
  (ok (get owner (default-to 
    {
      owner: tx-sender,
      creator: tx-sender,
      metadataUri: u"",
      dataHash: 0x,
      creationTimestamp: u0,
      lastModified: u0,
      isMetadataFrozen: false,
      royaltyPercentage: u0
    }
    (map-get? bioNftData nftId)
  )))
)

(define-read-only (getLastTokenId)
  (ok (var-get lastNftId))
)

(define-read-only (getTokenUri (nftId uint))
  (ok (get metadataUri (default-to
    {
      owner: tx-sender,
      creator: tx-sender,
      metadataUri: u"",
      dataHash: 0x,
      creationTimestamp: u0,
      lastModified: u0,
      isMetadataFrozen: false,
      royaltyPercentage: u0
    }
    (map-get? bioNftData nftId)
  )))
)

(define-read-only (getBioClassification (nftId uint))
  (ok (map-get? bioClassificationData nftId))
)

(define-read-only (getBioMetrics (nftId uint))
  (ok (map-get? bioMetricData nftId))
)

;; Public functions
(define-public (mint (metadataUri (string-utf8 256)) 
                    (dataHash (buff 32))
                    (royaltyPercentage uint)
                    (domain (string-utf8 64))
                    (kingdom (string-utf8 64))
                    (phylum (string-utf8 64))
                    (class (string-utf8 64))
                    (order (string-utf8 64))
                    (family (string-utf8 64))
                    (genus (string-utf8 64))
                    (species (string-utf8 64))
                    (geneSequence (string-utf8 1024))
                    (molecularWeight uint)
                    (proteinStructure (string-utf8 512))
                    (isolationDate uint)
                    (labCertification (string-utf8 256)))
  (let ((newNftId (+ (var-get lastNftId) u1))
        (currentTime (get-block-info? time (- block-height u1))))
    
    ;; Check constraints
    (asserts! (not (var-get contractPaused)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some currentTime) ERR_INVALID_TIMESTAMP)
    (asserts! (<= royaltyPercentage u100) ERR_ROYALTY_CONSTRAINTS)
    (asserts! (is-eq (len dataHash) u32) ERR_INVALID_DATA_HASH)
    
    ;; Validate input data
    (asserts! (validate-metadata-uri metadataUri) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string domain) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string kingdom) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string phylum) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string class) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string order) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string family) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string genus) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string species) ERR_EMPTY_STRING)
    (asserts! (validate-non-empty-string-1024 geneSequence) ERR_EMPTY_STRING)
    (asserts! (validate-molecular-weight molecularWeight) ERR_INVALID_MOLECULAR_WEIGHT)
    (asserts! (validate-non-empty-string-512 proteinStructure) ERR_EMPTY_STRING)
    (asserts! (validate-date isolationDate) ERR_INVALID_DATE)
    (asserts! (validate-non-empty-string-256 labCertification) ERR_EMPTY_STRING)
    
    ;; Mint the NFT
    (try! (nft-mint? bioNft newNftId tx-sender))
    
    ;; Store the NFT data
    (map-set bioNftData newNftId {
      owner: tx-sender,
      creator: tx-sender,
      metadataUri: metadataUri,
      dataHash: dataHash,
      creationTimestamp: (default-to u0 currentTime),
      lastModified: (default-to u0 currentTime),
      isMetadataFrozen: false,
      royaltyPercentage: royaltyPercentage
    })
    
    ;; Store the biological classification data
    (map-set bioClassificationData newNftId {
      domain: domain,
      kingdom: kingdom,
      phylum: phylum,
      class: class,
      order: order,
      family: family,
      genus: genus,
      species: species
    })
    
    ;; Store the biometric data
    (map-set bioMetricData newNftId {
      geneSequence: geneSequence,
      molecularWeight: molecularWeight,
      proteinStructure: proteinStructure,
      isolationDate: isolationDate,
      labCertification: labCertification
    })
    
    ;; Update the last NFT ID
    (var-set lastNftId newNftId)
    
    (ok newNftId)
  )
)

(define-public (transfer (nftId uint) (recipient principal))
  (begin
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Validate recipient
    (asserts! (validate-principal recipient) ERR_INVALID_INPUT)
    
    ;; Transfer the NFT
    (try! (nft-transfer? bioNft nftId tx-sender recipient))
    
    ;; Update the owner in the data map
    (let ((currentData (unwrap! (map-get? bioNftData nftId) ERR_NFT_DOES_NOT_EXIST))
          (currentTime (get-block-info? time (- block-height u1))))
      
      (map-set bioNftData nftId (merge currentData {
        owner: recipient,
        lastModified: (default-to u0 currentTime)
      }))
    )
    
    (ok true)
  )
)

(define-public (updateMetadata (nftId uint) (newMetadataUri (string-utf8 256)))
  (let ((currentData (unwrap! (map-get? bioNftData nftId) ERR_NFT_DOES_NOT_EXIST))
        (currentTime (get-block-info? time (- block-height u1))))
    
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Check if metadata is frozen
    (asserts! (not (get isMetadataFrozen currentData)) ERR_METADATA_FROZEN)
    
    ;; Validate new metadata URI
    (asserts! (validate-metadata-uri newMetadataUri) ERR_EMPTY_STRING)
    
    ;; Update the metadata
    (map-set bioNftData nftId (merge currentData {
      metadataUri: newMetadataUri,
      lastModified: (default-to u0 currentTime)
    }))
    
    (ok true)
  )
)

(define-public (updateBioClassification (nftId uint)
                                        (domain (string-utf8 64))
                                        (kingdom (string-utf8 64))
                                        (phylum (string-utf8 64))
                                        (class (string-utf8 64))
                                        (order (string-utf8 64))
                                        (family (string-utf8 64))
                                        (genus (string-utf8 64))
                                        (species (string-utf8 64)))
  (begin
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Validate taxonomy data
    (asserts! (validate-taxonomy-string domain) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string kingdom) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string phylum) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string class) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string order) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string family) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string genus) ERR_EMPTY_STRING)
    (asserts! (validate-taxonomy-string species) ERR_EMPTY_STRING)
    
    ;; Update the classification data
    (map-set bioClassificationData nftId {
      domain: domain,
      kingdom: kingdom,
      phylum: phylum,
      class: class,
      order: order,
      family: family,
      genus: genus,
      species: species
    })
    
    (ok true)
  )
)

(define-public (updateBioMetrics (nftId uint)
                                 (geneSequence (string-utf8 1024))
                                 (molecularWeight uint)
                                 (proteinStructure (string-utf8 512))
                                 (isolationDate uint)
                                 (labCertification (string-utf8 256)))
  (begin
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Validate biometric data
    (asserts! (validate-non-empty-string-1024 geneSequence) ERR_EMPTY_STRING)
    (asserts! (validate-molecular-weight molecularWeight) ERR_INVALID_MOLECULAR_WEIGHT)
    (asserts! (validate-non-empty-string-512 proteinStructure) ERR_EMPTY_STRING)
    (asserts! (validate-date isolationDate) ERR_INVALID_DATE)
    (asserts! (validate-non-empty-string-256 labCertification) ERR_EMPTY_STRING)
    
    ;; Update the biometric data
    (map-set bioMetricData nftId {
      geneSequence: geneSequence,
      molecularWeight: molecularWeight,
      proteinStructure: proteinStructure,
      isolationDate: isolationDate,
      labCertification: labCertification
    })
    
    (ok true)
  )
)

(define-public (freezeMetadata (nftId uint))
  (let ((currentData (unwrap! (map-get? bioNftData nftId) ERR_NFT_DOES_NOT_EXIST)))
    
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Freeze the metadata
    (map-set bioNftData nftId (merge currentData {
      isMetadataFrozen: true
    }))
    
    (ok true)
  )
)

;; Admin functions
(define-public (setContractOwner (newOwner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contractOwner)) ERR_NOT_AUTHORIZED)
    (asserts! (validate-principal newOwner) ERR_INVALID_INPUT)
    (var-set contractOwner newOwner)
    (ok true)
  )
)

(define-public (toggleContractPause)
  (begin
    (asserts! (is-eq tx-sender (var-get contractOwner)) ERR_NOT_AUTHORIZED)
    (var-set contractPaused (not (var-get contractPaused)))
    (ok true)
  )
)

(define-public (burn (nftId uint))
  (begin
    ;; Check if the NFT exists
    (asserts! (is-some (nft-get-owner? bioNft nftId)) ERR_NFT_DOES_NOT_EXIST)
    
    ;; Check if the sender is the owner
    (asserts! (is-eq (unwrap! (nft-get-owner? bioNft nftId) ERR_NFT_DOES_NOT_EXIST) tx-sender) ERR_NOT_NFT_OWNER)
    
    ;; Burn the NFT
    (try! (nft-burn? bioNft nftId tx-sender))
    
    ;; Clean up data maps
    (map-delete bioNftData nftId)
    (map-delete bioClassificationData nftId)
    (map-delete bioMetricData nftId)
    
    (ok true)
  )
)