import MarketplaceContract from Project.MarketplaceContract
import RegistryNFTContract from Registry.RegistryNFTContract
import FungibleToken from Flow.FungibleToken
import FlowToken from Flow.FlowToken

// Sets up any user (someone who wants to interact with the marketplace)
// by giving them a SaleCollection Resource defined in MarketplaceContract

transaction() {
    prepare(acct: AuthAccount) {
        // if the account doesn't already have a sale collection
        if acct.borrow<&MarketplaceContract.SaleCollection>(from: /storage/SaleCollection) == nil {
        
        // get a capability to the signer's public FlowToken Vault. We will pass this into
        // the SaleCollection so when someone buys from our SaleCollection, the FlowToken
        // gets deposited into this Capability.
        let ownerVault = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        assert(ownerVault.borrow() != nil, message: "Missing or mis-typed Token Vault")

        /** The reason we do this part is because we cannot do getCapability for something
        in storage, so because we need a Capability specifically we just put it in a private
        path and get it from there. By making it private its also only available to us **/
        acct.link<&RegistryNFTContract.Collection>(/private/NFTCollection, target: /storage/NFTCollection)
        
        let ownerNFTCollection = acct.getCapability<&RegistryNFTContract.Collection>(/private/NFTCollection)
        assert(ownerNFTCollection.borrow() != nil, message: "Missing or mis-typed NFT Collection")
        /** **/
        
        // create a new empty collection
        let saleCollection <- MarketplaceContract.createSaleCollection(ownerVault: ownerVault, ownerNFTCollection: ownerNFTCollection)
                
        // save it to the account
        acct.save(<-saleCollection, to: /storage/SaleCollection)

        // create a public capability for the collection
        acct.link<&MarketplaceContract.SaleCollection{MarketplaceContract.SalePublic}>(/public/SaleCollection, target: /storage/SaleCollection)
        }
    }

    execute {
        log("Gave account a Sale Collection")
    }
    
}