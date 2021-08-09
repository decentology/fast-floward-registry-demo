import RegistryNFTContract from Registry.RegistryNFTContract
import NonFungibleToken from Flow.NonFungibleToken

// sets up an account (any user who wants to interact with the Marketplace)
// the ability to deal with NFTs. It gives them an NFT Collection

transaction {

  prepare(acct: AuthAccount) {
    // if the account doesn't already have an NFT Collection
    if acct.borrow<&RegistryNFTContract.Collection>(from: /storage/NFTCollection) == nil {

      // create a new empty collection
      let nftCollection <- RegistryNFTContract.createEmptyCollection()
            
      // save it to the account
      acct.save(<-nftCollection, to: /storage/NFTCollection)

      // create a public capability for the collection
      acct.link<&RegistryNFTContract.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, RegistryNFTContract.INFTCollectionPublic}>(/public/NFTCollection, target: /storage/NFTCollection)
    
      log("Gave account an NFT Collection")
    }
  }

  execute {
    
  }
}
