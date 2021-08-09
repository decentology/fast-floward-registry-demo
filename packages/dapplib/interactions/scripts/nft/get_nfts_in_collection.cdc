import NonFungibleToken from Flow.NonFungibleToken
import RegistryNFTContract from Registry.RegistryNFTContract

pub fun main(acct: Address): [UInt64] {
  let acctNFTCollectionRef = getAccount(acct).getCapability(/public/NFTCollection)
            .borrow<&RegistryNFTContract.Collection{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow the public capability for the recipient's account")
  return acctNFTCollectionRef.getIDs()
}