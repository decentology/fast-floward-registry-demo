// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨
// ⚠️ THIS FILE IS AUTO-GENERATED WHEN packages/dapplib/interactions CHANGES
// DO **** NOT **** MODIFY CODE HERE AS IT WILL BE OVER-WRITTEN
// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨

const fcl = require("@onflow/fcl");

module.exports = class DappTransactions {

	static marketplace_buy_nft() {
		return fcl.transaction`
				import FungibleToken from 0xee82856bf20e2aa6
				import RegistryNFTContract from 0x01cf0e2f2f715450
				import MarketplaceContract from 0x01cf0e2f2f715450
				import NonFungibleToken from 0x01cf0e2f2f715450
				import FlowToken from 0x0ae53cb6e3f42a79
				
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
				
		`;
	}

	static marketplace_list_nft_for_sale() {
		return fcl.transaction`
				import MarketplaceContract from 0x01cf0e2f2f715450
				
				// Lists an NFT for sale
				
				transaction(id: UInt64, price: UFix64) {
				
				  let saleCollection: &MarketplaceContract.SaleCollection
				
				  prepare(acct: AuthAccount) {
				      self.saleCollection = acct.borrow<&MarketplaceContract.SaleCollection>(from: /storage/SaleCollection) 
				          ?? panic("Could not borrow the user's Sale Collection")
				  }
				
				  execute {
				      self.saleCollection.listForSale(id: id, price: price)
				
				      log("Listed NFT for sale")
				  }
				}
				
		`;
	}

	static marketplace_provision_account() {
		return fcl.transaction`
				import MarketplaceContract from 0x01cf0e2f2f715450
				import RegistryNFTContract from 0x01cf0e2f2f715450
				import FungibleToken from 0xee82856bf20e2aa6
				import FlowToken from 0x0ae53cb6e3f42a79
				
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
		`;
	}

	static nft_mint_nft() {
		return fcl.transaction`
				import NonFungibleToken from 0x01cf0e2f2f715450
				import RegistryNFTContract from 0x01cf0e2f2f715450
				
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
		`;
	}

	static nft_provision_account() {
		return fcl.transaction`
				import RegistryNFTContract from 0x01cf0e2f2f715450
				import NonFungibleToken from 0x01cf0e2f2f715450
				
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
				
		`;
	}

	static registry_nft_tenant() {
		return fcl.transaction`
				import RegistryNFTContract from 0x01cf0e2f2f715450
				import RegistryService from 0x01cf0e2f2f715450
				
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
				
		`;
	}

	static nft_transfer_nft() {
		return fcl.transaction`
				import RegistryNFTContract from 0x01cf0e2f2f715450
				import NonFungibleToken from 0x01cf0e2f2f715450
				
				// This transaction is used to transfer an NFT from acct --> recipient
				
				transaction(id: UInt64, recipient: Address) {
				  let giverNFTCollectionRef: &RegistryNFTContract.Collection
				  let recipientNFTCollectionRef: &RegistryNFTContract.Collection{NonFungibleToken.CollectionPublic}
				
				  prepare(acct: AuthAccount) {
				      self.giverNFTCollectionRef = acct.borrow<&RegistryNFTContract.Collection>(from: /storage/NFTCollection)
				        ?? panic("Could not borrow the user's NFT Collection")
				      self.recipientNFTCollectionRef = getAccount(recipient).getCapability(/public/NFTCollection)
				          .borrow<&RegistryNFTContract.Collection{NonFungibleToken.CollectionPublic}>()
				          ?? panic("Could not borrow the public capability for the recipient's account")
				  } 
				
				  execute {
				      let nft <- self.giverNFTCollectionRef.withdraw(withdrawID: id)
				      
				      self.recipientNFTCollectionRef.deposit(token: <-nft)
				
				      log("Transfered the NFT from the giver to the recipient")
				  }
				}
		`;
	}

	static registry_register_with_registry() {
		return fcl.transaction`
				import RegistryService from 0x01cf0e2f2f715450
				
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
		`;
	}

}
