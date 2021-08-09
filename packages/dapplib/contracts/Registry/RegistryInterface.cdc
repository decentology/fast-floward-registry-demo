/**

## The Decentology Multitenancy/Composable standard

## `RegistryInterface` contract interface

The interface that all multitenant contracts should conform to.
If a user wants to deploy a new multitenant contract, their contract would need
to implement the Tenant interface.

Their contract would have to follow all the rules and naming
that the interface specifies.

## `clientTenants` dictionary

A dictionary that maps the Address of a client to the amount of Tenants it has
created through calling `instance`.

## `Tenant` resource

The core resource type that represents an Tenant in the smart contract.

## `instance` function

A function that all clients can call to receive an Tenant resource. The client
passes in their Address so clientTenants can get updated.

## `getTenants` function

A function that returns clientTenants.

*/

import RegistryService from Registry.RegistryService

pub contract interface RegistryInterface {

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific RegistryContract.
    access(contract) var clientTenants: {Address: UInt64}

    // Tenant
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant to store all data and things
    // that would normally be saved to account storage in the contract's
    // init() function
    // 
    pub resource Tenant {}

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: &RegistryService.AuthNFT): @Tenant

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64}

    // Named Paths
    //
    pub let TenantStoragePath: StoragePath
    pub let TenantPublicPath: PublicPath
}
