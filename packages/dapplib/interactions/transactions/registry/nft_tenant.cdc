import RegistryNFTContract from Registry.RegistryNFTContract
import RegistryService from Registry.RegistryService

// This transaction allows any Tenant to receive a Tenant Resource from
// RegistryNFTContract. It saves the resource to account storage.
//
// Note that this can only be called by someone who has already registered
// with the RegistryService and received an AuthNFT.

transaction() {

  prepare(acct: AuthAccount) {
    // save the Tenant resource to the account if it doesn't already exist
    if acct.borrow<&RegistryNFTContract.Tenant>(from: /storage/NFTContract) == nil {
      // borrow a reference to the AuthNFT in account storage
      let authNFTRef = acct.borrow<&RegistryService.AuthNFT>(from: RegistryService.AuthStoragePath)
                        ?? panic("Could not borrow the AuthNFT")
      
      // save the new Tenant resource from RegistryNFTContract to account storage
      acct.save(<-RegistryNFTContract.instance(authNFT: authNFTRef), to: RegistryNFTContract.TenantStoragePath)

      // link the Tenant resource to the public with ITenant restrictions
      acct.link<&RegistryNFTContract.Tenant{RegistryNFTContract.ITenant}>(RegistryNFTContract.TenantPublicPath, target: RegistryNFTContract.TenantStoragePath)
    }
  }

  execute {
    log("Registered a new Tenant for RegistryNFTContract.")
  }
}
