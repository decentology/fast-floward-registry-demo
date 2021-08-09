import FungibleToken from Flow.FungibleToken
import RegistryNFTContract from Registry.RegistryNFTContract
import MarketplaceContract from Project.MarketplaceContract
import NonFungibleToken from Flow.NonFungibleToken
import FlowToken from Flow.FlowToken

// This transaction is used to purchase an NFT from a seller's Collection

transaction(id: UInt64, marketplaceAcct: Address) {

    let saleCollection: &MarketplaceContract.SaleCollection{MarketplaceContract.SalePublic}
    let userVaultRef: &FlowToken.Vault{FungibleToken.Provider}
    let userNFTCollection: &RegistryNFTContract.Collection{NonFungibleToken.Receiver}

    prepare(acct: AuthAccount) {

        self.saleCollection = getAccount(marketplaceAcct).getCapability(/public/SaleCollection)
            .borrow<&MarketplaceContract.SaleCollection{MarketplaceContract.SalePublic}>()
            ?? panic("Could not borrow from the Admin's Sale Collection")

        self.userVaultRef = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow reference to the owner's Vault!")

        self.userNFTCollection = acct.getCapability(/public/NFTCollection)
            .borrow<&RegistryNFTContract.Collection{NonFungibleToken.Receiver}>()
            ?? panic("Could not borrow from the user's NFT Collection")
    }

    execute {
        let cost = self.saleCollection.idPrice(id: id) ?? panic("An NFT with this id is not up for sale")
        let vault <- self.userVaultRef.withdraw(amount: cost)

        self.saleCollection.purchase(id: id, recipient: self.userNFTCollection, buyTokens: <-vault)
    }
}
