![matter-github-swift](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/web3swift-logo.png)

# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xe22b8979739d724343bd002f9f432f5990879901)
[![Build Status](https://travis-ci.com/matterinc/web3swift.svg?branch=develop)](https://travis-ci.com/matterinc/web3swift)
[![Stackoverflow](https://img.shields.io/badge/stackoverflow-ask-blue.svg)](https://stackoverflow.com/questions/tagged/web3swift)

<img align="left" width="25" height="25" src="https://user-images.githubusercontent.com/28599454/41086111-af4bc3b0-6a41-11e8-9f9f-2d642b12666e.png">[Ask questions](https://stackoverflow.com/questions/tagged/web3swift)

**web3swift** is your toolbelt for any kind interactions with Ethereum network.


  * [Features](#features)
  * [Design Decisions](#design-decisions)
  * [Requirements](#requirements)
  * [Migration Guides](#migration-guides)
  * [Communication](#communication)
  * [Installation](#installation)
    + [CocoaPods](#cocoapods)
    + [Carthage](#carthage)
  * [Example Project](#example-project)
  * [Popular questions](#popular-questions)
  * [Credits](#credits)
    + [Security Disclosure](#security-disclosure)
  * [Donations](#donations)
  * [License](#license)

---
  - [Usage Doc](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md)
	- **Account Management** 
		- [Create Account](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#create-account)
		- [Import Account](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#import-account)
		- [Manage Keystore](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#manage-keystore)
		- [Ethereum Address](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#ethereum-address)
		- [Get Balance](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#get-balance)
	- **Transactions Operations** 
		- [Prepare Transaction](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#prepare-transaction)
		- [Send Transaction](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#send-transaction)
	- **Chain State** 
		- [Get Block Number](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/Usage.md#get-block-number)


## Features

- [x] Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- [x] Interaction with remote node via JSON RPC :thought_balloon:
- [x] Smart-contract ABI parsing :book:
- [x] ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] RLP encoding
- [x] Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- [x] Local keystore management (`geth` compatible)
- [x] Batched requests in concurrent mode
- [x] Literally following the standards:
	- [x] [BIP32](https://github.com/bitcoin/bips/blob/feature/readmeImprovement/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
	- [x] [BIP39](https://github.com/bitcoin/bips/blob/feature/readmeImprovement/bip-0039.mediawiki) (Seed phrases)
	- [x] [BIP44](https://github.com/bitcoin/bips/blob/feature/readmeImprovement/bip-0044.mediawiki) (Key generation prefixes)
	- [x] [EIP-155](https://github.com/ethereum/EIPs/blob/feature/readmeImprovement/EIPS/eip-155.md) (Replay attacks protection) *enforced!*
- [x] Comprehensive Unit and Integration Test Coverage
- [x] [Complete Documentation](https://web3swift.github.io/web3swift)

## Design Decisions

- Not every JSON RPC function is exposed yet, and priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

## Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 9.0+
- Swift 4.1+

## Migration Guides

- [web3swift 2.0 Migration Guide](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/Documentation/web3swift%202.0%20Migration%20Guide.md)

## Communication

When using this lib, please make references to this repo and give your start! :)
*Nothing makes developers happier than seeing someone else use our work and go wild with it.*

If you are using web3swift in your app or know of an app that uses it, please add it to [this list](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift).

- If you **need help**, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift) and tag `web3swift`.
- If you need to **find or understand an API**, check [our documentation](http://web3swift.github.io/web3swift/).
- If you'd like to **see web3swift best practices**, check [Apps using this library](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift).
- If you **found a bug**, [open an issue](https://github.com/matterinc/web3swift/issues).
- If you **have a feature request**, [open an issue](https://github.com/matterinc/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/matterinc/web3swift/pulls).

## Installation

### CocoaPods

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

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate web3swift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "matterinc/web3swift" "carthage"
```

Run `carthage update` to build the framework and drag the built `web3swift.framework` into your Xcode project.

## Example Project

You can try lib by running the example project:

- Clone the repo: `git clone https://github.com/matterinc/web3swift.git`
- Move to the repo: `cd web3swift/Example/web3swiftExample`
- Install Dependencies: `pod install`
- Open: `open ./web3swiftExample.xcworkspace`

## Popular questions

#### Is it possible to get Mnemonic Phrase (Seed Phrase) from Private key using web3swift?

In web3swift there is no backward conversion from Private key to Mnemonic Phrase. Also it is theoretically impossible to recover a phrase from a Private key. After Seed Phrase is converted to some initial entropy the “master key is derived” and the initial entropy is discarded.

The simplest solution is to encrypt the phrase using users pincode and save it in some other secure keystore.
Mnemonic Phrase is very sensitive data and you must be very careful to let the user get it.
Our advise if you want to show it to user - ask to save a Passphrase when creating BIP32Keystore. 

#### How to interact with custom smart-contract with web3swift?

For example: you want to interact with smart-contract and all you know is - its address (address example: 0xfa28eC7198028438514b49a3CF353BcA5541ce1d).

You can get the ABI of your contract directly from [Remix IDE](https://remix.ethereum.org/) ([Solution](https://ethereum.stackexchange.com/questions/27536/where-to-find-contract-abi-in-new-version-of-online-remix-solidity-compiler?rq=1))

Then you should use contract address and ABI in creating contract object:
```swift
let contract = Web3.InfuraMainnetWeb3().contract(<abiString: String>, at: <EthereumAddress?>, abiVersion: <Int>)
```
To create transaction you should call some contract method:
```swift
let transaction = contract.method(<method: String>, parameters: <[AnyObject]>, extraData: <Data>, options: <Web3Options?>)
```

Here is the function example that creates TransactionIntermediate object, that you can send to smart-contract:
```swift
let yourContractABI = """
<CONTRACT JSON ABI>
"""

func prepareTransaction(parameters: Data, gasLimit: BigUInt = 27500, completion: @escaping (Result<TransactionIntermediate>) -> Void) {
    DispatchQueue.global().async {
        guard let addressFrom: String = <YOURS WALLET ADDRESS> else {return}
        guard let ethAddressFrom = EthereumAddress(addressFrom) else {return}

        let yourContractAddress = "<CONTRACT ETH ADDRESS>"
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}

        let web3 = Web3.InfuraMainnetWeb3() //or any test network
        web3.addKeystoreManager(KeystoreManager.defaultManager)

        var options = Web3Options.defaultOptions()
        options.from = ethAddressFrom
        options.value = 0 // or any other value you want to send

        guard let contract = web3.contract(yourContractJsonABI, at: ethContractAddress, abiVersion: 2) else {return}

        guard let gasPrice = web3.eth.getGasPrice().value else {return}
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit

        guard let transaction = contract.method("<METHOD OF CONTRACT YOU WANT TO CALL>", parameters: [parameters] as [AnyObject], options: options) else {return}
        guard case .success(let estimate) = transaction.estimateGas(options: options) else {return} //here is estimated gas - something like confirming that you made a transaction correctly
        print("estimated cost: \(estimate)")

        DispatchQueue.main.async {
            completion(Result.Success(transaction))
        }
    }
}
```

## Credits

Alex Vlasov, [@shamatar](https://github.com/shamatar),  alex.m.vlasov@gmail.com

Petr Korolev, [@skywinder](https://github.com/skywinder)

### Security Disclosure

If you believe you have identified a security vulnerability with web3swift, you should report it as soon as possible via email to [Alex Vlasov](https://github.com/shamatar) alex.m.vlasov@gmail.com. Please do not post it to a public issue tracker.

## Donations

[The Matters](https://github.com/orgs/matterinc/people) are charged with open-sorсe and do not require money for using their web3swift lib.
We want to continue to do everything we can to move the needle forward.
If you use any of our libraries for work, see if your employers would be interested in donating. Any amount you can donate today to help us reach our goal would be greatly appreciated.

Our Ether wallet address: 0xe22b8979739d724343bd002f9f432f5990879901

![Donate](http://qrcoder.ru/code/?0xe22b8979739d724343bd002f9f432f5990879901&4&0)

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matterinc/web3swift/blob/feature/readmeImprovement/LICENSE) for details.
