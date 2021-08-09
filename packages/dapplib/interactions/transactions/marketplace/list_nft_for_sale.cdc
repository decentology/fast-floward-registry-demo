import MarketplaceContract from Project.MarketplaceContract

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
