import RegistryService from Registry.RegistryService

// Allows a Tenant to register with the RegistryService. It will
// save an AuthNFT to account storage. Once an account
// has an AuthNFT, they can then get Tenant Resources from any contract
// in the Registry.
//
// Note that this only ever needs to be called once per Tenant

transaction() {

    prepare(acct: AuthAccount) {
        // if this account doesn't already have an AuthNFT...
        if acct.borrow<&RegistryService.AuthNFT>(from: RegistryService.AuthStoragePath) == nil {
            // save a new AuthNFT to account storage
            acct.save(<-RegistryService.register(), to: RegistryService.AuthStoragePath)  
        }
    }

    execute {

    }
}