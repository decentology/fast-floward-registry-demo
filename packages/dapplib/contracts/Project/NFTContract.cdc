import NonFungibleToken from Flow.NonFungibleToken

// An example of a NFT Contract that does not exist in the Registry.
// This is not multi-tenant and not composable. This type of
// contract would be deployed many different times by different accounts
// because the data could only belong to 1 account. We solve this problem
// with RegistryNFTContract.

// You will not be using this contract, it is simply here to help define
// a contrast between a non-composable contract (this one) and a 
// composable one (RegistryNFTContract)

pub contract NFTContract: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: {String: String}

        init(_metadata: {String: String}) {
            self.id = NFTContract.totalSupply
            self.metadata = _metadata

            NFTContract.totalSupply = NFTContract.totalSupply + (1 as UInt64)
        }
    }

    pub resource interface INFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT

        pub fun borrowEntireNFT(id: UInt64): &NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow NFT reference: The ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, INFTCollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @NFTContract.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its id and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowEntireNFT gets a reference to an NFT in the collection
        // so that the caller can read its id & metadata and call its methods
        pub fun borrowEntireNFT(id: UInt64): &NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &NFT
            } else {
                return nil
            }
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &NFTContract.Collection{NonFungibleToken.CollectionPublic}, metadata: {String: String}) {

            // create a new NFT
            var newNFT <- create NFT(_metadata: metadata)

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)
        }
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0

        emit ContractInitialized()

        // save the NFTMinter to account storage
        self.account.save(<- create NFTMinter(), to: /storage/NFTContractMinter)
    }
}