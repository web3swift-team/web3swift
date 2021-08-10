# web3swift
**web3swift** is an iOS toolbelt for interaction with the Ethereum network.

![matter-github-swift](https://github.com/matter-labs/web3swift/blob/develop/web3swift-logo.png)
[![Build Status](https://travis-ci.com/matter-labs/web3swift.svg?branch=develop)](https://travis-ci.com/matter-labs/web3swift)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/web3.swift.pod.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xe22b8979739d724343bd002f9f432f5990879901)
[![Stackoverflow](https://img.shields.io/badge/stackoverflow-ask-blue.svg)](https://stackoverflow.com/questions/tagged/web3swift)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Core features](#core-features)
- [Installation](#installation)
  - [Example usage](#example-usage)
      - [Send Ether](#send-ether)
      - [Send ERC-20 Token](#send-erc-20-token)
      - [Write Transaction and call smart contract method](#write-transaction-and-call-smart-contract-method)
  - [Web3View example](#web3view-example)
  - [Build from source](#build-from-source)
  - [Requirements](#requirements)
  - [Migration Guides](#migration-guides)
- [Documentation](#documentation)
- [Projects that are using web3swift](#projects-that-are-using-web3swift)
- [Support](#support)
- [Contribute](#contribute)
  - [Future steps](#future-steps)
- [Credits](#credits)
- [Security Disclosure](#security-disclosure)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Core features

- [x] :zap: Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality 
- [x] :thought_balloon: Interaction with remote node via **JSON RPC** 
- [x] 🔐 Local **keystore management** (`geth` compatible)
- [x] 🤖 Smart-contract **ABI parsing** 
- [x] 🔓**ABI deconding** (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] 🕸Ethereum Name Service **(ENS) support** - a secure & decentralised way to address resources both on and off the blockchain using simple, human-readable names
- [x] :arrows_counterclockwise: **Smart contracts interactions** (read/write) 
- [x]  ⛩ **Infura support**, patial Websockets API support
- [x] ⚒  **Parsing TxPool** content into native values (ethereum addresses and transactions) - easy to get pending transactions
- [x] 🖇 **Event loops** functionality
- [x] 📱Supports Web3View functionality (WKWebView with **injected "web3" provider**)
- [x] 🕵️‍♂️ Possibility to **add or remove "middleware" that intercepts**, modifies and even **cancel transaction** workflow on stages "before assembly", "after assembly"and "before submission"
- [x] ✅**Literally following the standards** (BIP, EIP, etc):

    - [x] **[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) (HD Wallets), [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases), [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)**
- [x] **[EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)** (Standart interface for tokens - ERC-20), **[EIP-67](https://github.com/ethereum/EIPs/issues/67)** (Standard URI scheme), **[EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md)** (Replay attacks protection)
    - [x] **And many others** *(For details about this EIP's look at [Documentation page](https://github.com/matter-labs/web3swift/blob/master/Documentation/))*: EIP-681, EIP-721, EIP-165, EIP-777, EIP-820, EIP-888, EIP-1400, EIP-1410, EIP-1594, EIP-1643, EIP-1644, EIP-1633, EIP-721, EIP-1155, EIP-1376, ST-20

- [x] 🗜 **Batched requests** in concurrent mode
- [x] **RLP encoding**
- [x] Base58 encoding scheme
- [x] Formatting to and from Ethereum Units
- [x] Comprehensive Unit and Integration Test Coverage

## Installation

- CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

To integrate web3swift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target '<Your Target Name>' do
    use_frameworks!
    pod 'web3swift'
end

```


Then, run the following command:

```bash
$ pod install
```

- Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate web3swift into your Xcode project using Carthage, specify it in your `Cartfile`.
Create an empty Cartfile with the touch command and open it:

```bash
$ touch Cartfile
$ open -a Xcode Cartfile
```

Add the following line to the Cartfile and save it:

```ogdl
github "matter-labs/web3swift" "master"
```

Run `carthage update` to build the framework. By default, Carthage performs checkouts and creates a new directory 'Carthage' in the same location as your Cartfile. Open this directory, go to 'Build' directory, choose iOS or macOS directory, and use the selected directory framework in your Xcode project.

- Swift Package
Open xcode setting and add this repo as a source

### Example usage


##### Send Ether

```swift
let value: String = "1.0" // In Ether
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let toAddress = EthereumAddress(toAddressString)!
let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let tx = contract.write(
    "fallback",
    parameters: [AnyObject](),
    extraData: Data(),
    transactionOptions: options)!
```

##### Send ERC-20 Token

```swift
let web3 = Web3.InfuraMainnetWeb3() 
let value: String = "1.0" // In Tokens
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let toAddress = EthereumAddress(toAddressString)!
let erc20ContractAddress = EthereumAddress(token.address)!
let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let method = "transfer"
let tx = contract.write(
    method,
    parameters: [toAddress, amount] as [AnyObject],
    extraData: Data(),
    transactionOptions: options)!
```


##### Get account balance
```swift
let web3 = Web3.InfuraMainnetWeb3() 
let address = EthereumAddress("<Address>")!
let balance = try web3.eth.getBalance(address: address)
let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
```

##### Write Transaction and call smart contract method

```swift
let web3 = Web3.InfuraMainnetWeb3() 
let value: String = "0.0" // Any amount of Ether you need to send
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let contractMethod = "SOMECONTRACTMETHOD" // Contract method you want to write
let contractABI = "..." // Contract ABI
let contractAddress = EthereumAddress(contractAddressString)!
let abiVersion = 2 // Contract ABI version
let parameters: [AnyObject] = [...]() // Parameters for contract method
let extraData: Data = Data() // Extra data for contract method
let contract = web3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let tx = contract.write(
    contractMethod,
    parameters: parameters,
    extraData: extraData,
    transactionOptions: options)!
```

### Web3View example

You can see how to our demo project: **WKWebView with injected "web3" provider**:

``` bash
git clone https://github.com/matter-labs/web3swift.git
cd web3swift/Example/web3swiftBrowser
pod install
open ./web3swiftBrowser.xcworkspace
```

### Build from source

- Clone repo
- Instal dependencies via  `./carthage-build.sh --platform iOS` (temp workaround, foe of Carthage bug. [For details please look at](https://github.com/Carthage/Carthage/issues/3019#issuecomment-665136323)

### Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 10.2+
- Swift 5.0+

### Migration Guides

- [web3swift 2.0 Migration Guide](https://github.com/matterinc/web3swift/blob/master/Documentation/web3swift%202.0%20Migration%20Guide.md)

## Documentation

For full documentation details and FAQ, please look at [Documentation](https://github.com/matter-labs/web3swift/blob/master/Documentation/)

*If you need to find or understand an API, check [Usage.md](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md).*

 **FAQ moved [Documentation Page](https://github.com/matter-labs/web3swift/blob/master/Documentation/)**

Here are quick references for essential features:

- [Preffered models](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#preffered-models)
- [Account Management (create, import, private keys managments, etc.)](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#account-management)
- [Ethereum Endpoints interaction (web3, balance, tx's operations, chain state)](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#ethereum-endpoints-interaction)
- [Websockets](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#websockets)
- [ENS](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#ens)

## Projects that are using web3swift

If you are using this library in your project, please [add a link](https://github.com/matter-labs/web3swift/edit/develop/README.md) to this repo.

* [MyEtherWallet/MEWconnect-iOS](https://github.com/MyEtherWallet/MEWconnect-iOS)
* [Peepeth iOS client](https://github.com/matterinc/PeepethClient)
* [Ethereum & ERC20Tokens Wallet](https://itunes.apple.com/us/app/ethereum-erc20tokens-wallet/id1386738877?ls=1&mt=8)
* [Pay-iOS](https://github.com/BANKEX/Pay-iOS)
* [GeoChain](https://github.com/awallish/GeoChain)
* [NewHorizonLabs/TRX-Wallet](https://github.com/NewHorizonLabs/TRX-Wallet)
* [SteadyAction/EtherWalletKit](https://github.com/SteadyAction/EtherWalletKit)
* [UP Wallet/loopr-ios](https://github.com/Loopring/loopr-ios)
* [MyENS Wallet](https://github.com/barrasso/enswallet)
* [LoanStar](https://github.com/barrasso/loan-star)
* [AlphaWallet](https://github.com/AlphaWallet/alpha-wallet-ios)
* [Follow_iOS](https://github.com/FollowInc/Follow_iOS)
* [Biomedical Data Sharing dApp - Geolocation](https://github.com/HD2i/Geolocation-iOS)
* [Alice Wallet](https://github.com/alicedapp/AliceX)
* [web3-react-native](https://github.com/cawfree/web3-react-native)
* [YOUR APP CAN BE THERE (click me)](https://github.com/matter-labs/web3swift/edit/develop/README.md) :wink:

*Nothing makes developers happier than seeing someone else use our work and go wild with it.*

## Support

- If you **need help**, [open an issue](https://github.com/matter-labs/web3swift/issues).
- If you'd like to **see web3swift best practices**, check [Projects that using web3swift](https://github.com/matter-labs/web3swift#projects-that-using-web3swift).
- If you **found a bug**, [open an issue](https://github.com/matter-labs/web3swift/issues).


## Contribute

Want to improve? It's awesome:

Then good news for you: **We are ready to pay for your contribution via [@gitcoin bot](https://gitcoin.co/grants/358/web3swift)!**

- If you **have a feature request**, [open an issue](https://github.com/matter-labs/web3swift/issues).

- If you **want to contribute**, read [contribution policy](https://github.com/matter-labs/web3swift/blob/master/Documentation/CONTRIBUTION_POLICY.md) & [submit a pull request](https://github.com/matter-labs/web3swift/pulls).

If you use any of our libraries for work, see if your employers would be interested in donating. Any amount you can donate today to help us reach our goal would be much appreciated.

[Matter Labs](https://github.com/orgs/matter-labs/people) are charged with open-sourсe and do not require money for using their web3swift lib.
We want to continue to do everything we can to move the needle forward.

- **Support us** via [@gitcoin Grant program](https://gitcoin.co/grants/358/web3swift)
- Ether wallet address: `0x6A3738c6299f45c31697aceA647D49EdCC9C28A4`

<img src="https://raw.githubusercontent.com/matter-labs/web3swift/develop/img/Ether-donations.jpeg" width="300" />

### Future steps 

You are more than welcome to participate! **Your contribution will be paid via  [@gitcoin Grant program](https://gitcoin.co/grants/358/web3swift).**

- [ ] **L2 support** (such as [ZkSync](https://zksync.io/))

- [ ] **Modularity** with the basic Web3 subspec/SPM (the most basic functions like transaction signing and interacting with an http rpc server) and other modules with additional functionality

- [ ] Complete Documentation (https://web3swift.github.io/web3swift)

- [ ] Performance Improvements

- [ ] Convenient methods for namespaces

  

## Credits

- Alex Vlasov, [@shamatar](https://github.com/shamatar)
- Petr Korolev, [@skywinder](https://github.com/skywinder)
- Anton Grigorev, [@baldyash](https://github.com/BaldyAsh)

## Security Disclosure

If you believe you have identified a security vulnerability with web3swift, you should report it as soon as possible via email to [hello@matter-labs.io](mailto:hello@matter-labs.io). Please do not post it to a public issue tracker.


## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matter-labs/web3swift/blob/master/LICENSE) for details.
