<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Design Decisions](#design-decisions)
- [Core features:](#core-features)
- [FAQ](#faq)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Design Decisions

- Functionality was focused on serializing and **signing transactions locally** on the device to **send raw transactions** to the Ethereum network
- **Requirements for password input** on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for **private key export** is exposed for user convenience but marked as `UNSAFE_`. Typical workflow takes care of EIP155 compatibility and proper clearing of private key data from memory


## Core features:

- [x] Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- [x] Interaction with remote node via **JSON RPC** :thought_balloon:
- [x] Local **keystore management** (`geth` compatible)
- [x] Smart-contract **ABI parsing** :book:
- [x] **ABI deconding** (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] Ethereum Name Service **(ENS) support** - a secure & decentralised way to address resources both on and off the blockchain using simple, human-readable names
- [x] **Smart contracts interactions** (read/write) :arrows_counterclockwise:
- [x] Complete **Infura support**, patial Websockets API support
- [x] **Parsing TxPool** content into native values (ethereum addresses and transactions) - easy to get pending transactions
- [x] **Event loops** functionality
- [x] Supports Web3View functionality (WKWebView with **injected "web3" provider**)
- [x] Possibility to **add or remove "middleware" that intercepts**, modifies and even **cancel transaction** workflow on stages "before assembly", "after assembly"and "before submission"
- [x] **Literally following the standards:**
    - [x] [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
    - [x] [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
    - [x] [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
    - [x] [EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) (A standard interface for tokens - ERC-20)
    - [x] [EIP-67](https://github.com/ethereum/EIPs/issues/67) (Standard URI scheme)
    - [x] [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *enforced!*
    - [x] [EIP-681](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md) (A standard way of representing various transactions, especially payment requests in Ethers and ERC-20 tokens as URLs)
    - [x] [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) (A standard interface for non-fungible tokens, also known as deeds - ERC-721)
    - [x] [EIP-165](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md) (Standard Interface Detection, also known as ERC-165)
    - [x] [EIP-777](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md) (New Advanced Token Standard, also known as ERC-777)
    - [x] [EIP-820](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-820.md) (Pseudo-introspection Registry Contract, also known as ERC-820)
    - [x] [EIP-888](https://github.com/ethereum/EIPs/issues/888) (MultiDimensional Token Standard, also known as ERC-888)
    - [x] [EIP-1400](https://github.com/ethereum/EIPs/issues/1411) (Security Token Standard, also known as ERC-1400)
    - [x] [EIP-1410](https://github.com/ethereum/EIPs/issues/1410) (Partially Fungible Token Standard, also known as ERC-1410)
    - [x] [EIP-1594](https://github.com/ethereum/EIPs/issues/1594) (Core Security Token Standard, also known as ERC-1594)
    - [x] [EIP-1643](https://github.com/ethereum/EIPs/issues/1643) (Document Management Standard, also known as ERC-1643)
    - [x] [EIP-1644](https://github.com/ethereum/EIPs/issues/1644) (Controller Token Operation Standard, also known as ERC-1644)
    - [x] [EIP-1633](https://github.com/ethereum/EIPs/issues/1634) (Re-Fungible Token, also known as ERC-1633)
    - [x] [EIP-721x](https://github.com/loomnetwork/erc721x) (An extension of ERC721 that adds support for multi-fungible tokens and batch transfers, while being fully backward-compatible, also known as ERC-721x)
    - [x] [EIP-1155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md) (Multi Token Standard, also known as ERC-1155)
    - [x] [EIP-1376](https://github.com/ethereum/EIPs/issues/1376) (Service-Friendly Token, also known as ERC-1376)
    - [x] [ST-20](https://github.com/PolymathNetwork/polymath-core) - ST-20 token is an Ethereum-based token implemented on top of the ERC-20 protocol that adds the ability for tokens to control transfers based on specific rules

## FAQ

> Is it possible to get a Mnemonic Phrase (Seed Phrase) from Private key using web3swift?

In web3swift, there is no backward conversion from the Private key to Mnemonic Phrase. Also, it is theoretically impossible to recover a phrase from a Private key. After Seed Phrase is converted to some initial entropy, the "master key is derived," and the **initial entropy is discarded**.

The simplest solution is to encrypt the phrase using the user's pin code and save it in some other secure keystore.
The mnemonic phrase is very sensitive data, and you must be very careful to let the user get it.
Our advice if you want to show it to a user - ask to save a Passphrase when creating BIP32Keystore.

> How to interact with custom smart-contract with web3swift?

For example: you want to interact with smart-contract and all you know is - its address (address example: 0xfa28eC7198028438514b49a3CF353BcA5541ce1d).

You can get the ABI of your contract directly from [Remix IDE](https://remix.ethereum.org/) ([Solution](https://ethereum.stackexchange.com/questions/27536/where-to-find-contract-abi-in-new-version-of-online-remix-solidity-compiler?rq=1))

Then you should use contract address and ABI in creating contract object. In example we use Infura Mainnet:

```swift
let yourContractABI: String = <CONTRACT JSON ABI>
let toEthereumAddress: EthereumAddress = <DESTINATION ETHEREUM ADDRESS>
let abiVersion: Int = <ABI VERSION NUMBER>

let contract = Web3.InfuraMainnetWeb3().contract(yourContractABI, at: toEthereumAddress, abiVersion: abiVersion)
```

Here is the example how you should call contract method:

```swift
let method: String = <CONTRACT METHOD NAME>
let parameters: [AnyObject] = <PARAMETERS>
let extraData: Data = <DATA>
let transactionOptions: TransactionOptions = <OPTIONS>

let transaction = contract.read(method, parameters: parameters, extraData: extraData, transactionOptions: transactionOptions)
```

Here is the example how you should send transaction to some contract method:

```swift
let method: String = <CONTRACT METHOD NAME>
let parameters: [AnyObject] = <PARAMETERS>
let extraData: Data = <DATA>
let transactionOptions: TransactionOptions = <OPTIONS>
let transaction = contract.write(method, parameters: parameters, extraData: extraData, transactionOptions: transactionOptions)
```

> How to test on a local node?

```swift
func setLocalNode(port: Int = 8545) -> Web3? {
    guard let web3 = Web3(url: URL(string: "http://127.0.0.1:\(port)")!) else { return nil }
    return web3
}
```

