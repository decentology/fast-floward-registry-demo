import NonFungibleToken from Flow.NonFungibleToken
import RegistryNFTContract from Registry.RegistryNFTContract

// This transction uses the NFTMinter resource to mint a new NFT.
//
// It must be run with the account that has a minter resource. In this case,
// we are calling the transaction with the Tenant itself because it stores
// an NFTMinter resource in the Tenant resource

transaction(recipient: Address, metadata: {String: String}) {
    
    // the tenant
    let tenant: &RegistryNFTContract.Tenant
    let receiver: &RegistryNFTContract.Collection{NonFungibleToken.CollectionPublic}

    prepare(acct: AuthAccount) {

        self.tenant = acct.borrow<&RegistryNFTContract.Tenant>(from: RegistryNFTContract.TenantStoragePath)
                        ?? panic("Could not borrow the Tenant")
         // borrow the recipient's public NFT collection reference
        self.receiver = getAccount(recipient).getCapability(/public/NFTCollection)
            .borrow<&RegistryNFTContract.Collection{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
        
    }

    execute {
        // get a reference to an NFTMinter resource from the Tenant
        let minter = self.tenant.minterRef()

        // mint the NFT and deposit it to the recipient's collection
        minter.mintNFT(tenant: self.tenant, recipient: self.receiver, metadata: metadata)
    }
}