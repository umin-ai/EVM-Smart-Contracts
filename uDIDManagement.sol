// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title uminaiDID
 * @notice This contract implements a custom DID method (e.g., did:mycompany)
 *         by managing a pointer (IPFS CID) to the full DID Document stored off-chain.
 */
contract uminaiDID {
    
    struct DIDDocumentPointer {
        address owner;   // Owner of the DID (the address that created it)
        string ipfsCID;  // IPFS CID pointing to the full DID Document
        bool exists;     // Flag indicating if the DID exists
    }
    
    // Mapping from DID (a string) to its DID Document pointer.
    mapping(string => DIDDocumentPointer) public didPointers;
    
    // Events for tracking DID operations.
    event DIDCreated(string indexed did, address indexed owner, string ipfsCID);
    event DIDUpdated(string indexed did, string newIpfsCID);
    event DIDRevoked(string indexed did);
    
    /**
     * @notice Create a new DID Document pointer.
     * @param _did The custom DID (e.g., "did:mycompany:12345").
     * @param _ipfsCID The IPFS CID where the full DID Document is stored.
     */
    function createDID(string memory _did, string memory _ipfsCID) public {
        // Define the required prefix.
        bytes memory requiredPrefix = bytes("did:uminai:");
        bytes memory didBytes = bytes(_did);

        // Ensure the DID is at least as long as the prefix plus additional characters.
        require(didBytes.length > requiredPrefix.length, "DID must include an identifier after did:uminai:");

        // Compare the prefix.
        for (uint i = 0; i < requiredPrefix.length; i++) {
            require(didBytes[i] == requiredPrefix[i], "DID must start with did:uminai:");
        }
        
        // Ensure that the DID doesn't already exist.
        require(!didPointers[_did].exists, "DID already exists");

        didPointers[_did] = DIDDocumentPointer({
            owner: msg.sender,
            ipfsCID: _ipfsCID,
            exists: true
        });

        emit DIDCreated(_did, msg.sender, _ipfsCID);
    }

    
    /**
     * @notice Update the DID Document pointer. Only the owner can update.
     * @param _did The DID to update.
     * @param _newIpfsCID The new IPFS CID for the updated DID Document.
     */
    function updateDID(string memory _did, string memory _newIpfsCID) public {
        require(didPointers[_did].exists, "DID does not exist");
        require(didPointers[_did].owner == msg.sender, "Caller is not the owner");
        
        didPointers[_did].ipfsCID = _newIpfsCID;
        emit DIDUpdated(_did, _newIpfsCID);
    }
    
    /**
     * @notice Revoke (delete) a DID Document pointer. Only the owner can revoke.
     * @param _did The DID to revoke.
     */
    function revokeDID(string memory _did) public {
        require(didPointers[_did].exists, "DID does not exist");
        require(didPointers[_did].owner == msg.sender, "Caller is not the owner");
        
        delete didPointers[_did];
        emit DIDRevoked(_did);
    }
    
    /**
     * @notice Query a DID Document pointer.
     * @param _did The DID to query.
     * @return The DIDDocumentPointer struct.
     */
    function queryDID(string memory _did) public view returns (DIDDocumentPointer memory) {
        require(didPointers[_did].exists, "DID does not exist");
        return didPointers[_did];
    }
}
