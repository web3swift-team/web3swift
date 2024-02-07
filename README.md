# web3swift
**web3swift** is an iOS toolbelt for interaction with the Ethereum network.

## Social media
[Join our discord](https://discord.gg/8bHCNmhS7x) or [Telegram](https://t.me/web3swift) if you need support or want to contribute to web3swift development!

![matter-github-swift](https://github.com/web3swift-team/web3swift/blob/develop/web3swift-logo.png)
[![Web3swift CI](https://github.com/web3swift-team/web3swift/actions/workflows/macOS-tests.yml/badge.svg)](https://github.com/web3swift-team/web3swift/actions/workflows/macOS-tests.yml)
[![Swift](https://img.shields.io/badge/Swift-5.5-f26118.svg?style=flat)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](https://github.com/web3swift-team/web3swift/blob/master/LICENSE.md)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xe22b8979739d724343bd002f9f432f5990879901)
[![Stackoverflow](https://img.shields.io/badge/stackoverflow-ask-blue.svg)](https://stackoverflow.com/questions/tagged/web3swift)

---

<!-- MarkdownTOC -->

- [Core Features](#core-features)
- [Installation](#installation)
    - [Swift Package](#swift-package)
    - [CocoaPods](#cocoapods)
- [Example usage](#example-usage)
    - [Create Web3 Provider](#create-web3-provider)
    - [Create Web3 Object](#create-web3-object)
    - [Send Ether](#send-ether)
    - [Contract read method](#contract-read-method)
    - [Write Transaction and call smart contract method](#write-transaction-and-call-smart-contract-method)
    - [Sending network request to a node](#sending-network-request-to-a-node)
- [Build from source](#build-from-source)
    - [SPM](#spm)
- [Requirements](#requirements)
- [Documentation](#documentation)
- [Projects that are using web3swift](#projects-that-are-using-web3swift)
- [Support](#support)
- [Contribute](#contribute)
    - [Contribution](#contribution)
- [Credits](#credits)
- [Security Disclosure](#security-disclosure)
- [License](#license)

<!-- /MarkdownTOC -->



## Core features

- [x] :zap: Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality
- [x] :thought_balloon: Interaction with remote node via **JSON RPC**
- [x] 🔐 Local **keystore management** (`geth` compatible)
- [x] 🤖 Smart-contract **ABI parsing**
- [x] 🔓**ABI decoding** (V2 is supported with a return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] 🕸Ethereum Name Service **(ENS) support** - a secure & decentralised way to address resources both on and off the blockchain using simple, human-readable names
- [x] :arrows_counterclockwise: **Smart contracts interactions** (read/write)
- [x]  ⛩ **Infura support**
- [x] ⚒  **Parsing TxPool** content into native values (Ethereum addresses and transactions) - easy to get pending transactions
- [x] 🖇 **Event loops** functionality
- [x] 🕵️‍♂️ Possibility to **add or remove "middleware" that intercepts**, modifies and even **cancel transaction** workflow on stages "before assembly", "after assembly" and "before submission"
- [x] ✅**Literally following the standards** (BIP, EIP, etc):
    - [x] **[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) (HD Wallets), [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases), [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)**
- [x] **[EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)** (Standard interface for tokens - ERC-20), **[EIP-67](https://github.com/ethereum/EIPs/issues/67)** (Standard URI scheme), **[EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md)** (Replay attacks protection), **[EIP-2718](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2718.md)** (Typed Transaction Envelope), **[EIP-1559](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md)** (Gas Fee market change)
    - [x] **And many others** *(For details about this EIP's look at [Documentation page](https://github.com/web3swift-team/web3swift/blob/master/Documentation/))*: EIP-165, EIP-681, EIP-721, EIP-777, EIP-820, EIP-888, EIP-1155, EIP-1376, EIP-1400, EIP-1410, EIP-1594, EIP-1633, EIP-1643, EIP-1644, EIP-4361 ([SIWE](https://eips.ethereum.org/EIPS/eip-4361)), ST-20
- [x] **RLP encoding**
- [x] Base58 encoding scheme
- [x] Formatting to and from Ethereum Units
- [x] Comprehensive Unit and Integration Test Coverage

## Installation

### Swift Package
The [Swift Package Manager](https://swift.org/package-manager/ "") is a tool for automating the distribution of Swift code that is well integrated with Swift build system.

Once you have your Swift package set up, adding `web3swift` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.
```swift
dependencies: [
    .package(url: "https://github.com/web3swift-team/web3swift.git", .upToNextMajor(from: "3.0.0"))
]
```

Or if your project is not a package follow these guidelines on [how to add a Swift Package to your Xcode project](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).


## Example usage
In the imports section:

```swift
import web3swift
import Web3Core
```

### CocoaPods

CocoaPods is not supported.

### Create Web3 Provider
Currently, web3swift supports only HTTP providers. WebSocket provider support was removed and is planned to be rebuilt from scratch.
To create a Web3HttpProvider you only need an RPC URL:
```swift
try await Web3HttpProvider(url: rpcUrl)
```

But if you know chain ID upfront it's better to specify one as well as with chain ID, the initializer won't have to ask the RPC for it and thus you guarantee that the initializer completes successfully without any asynchronous calls, considering your URL using `http/s` scheme:
```swift
let optionalChainId: Networks = .Custom(networkID: 42)
try await Web3HttpProvider(url: rpcUrl, network: optionalChainId)
```

Specify a keystore manager for the Web3HttpProvider if you want `web3.personal` namespace to work as it relies on use of the keystore:
```swift
try await Web3HttpProvider(url: rpcUrl, network: optionalChainId, keystoreManager: optionalKeystoreManager)
```

### Create Web3 Object
Creating a Web3 object is quite simple once you have a Web3 HTTP provider:
```swift
Web3(provider: provider)
```

Or if you are a user of Infura:
```swift
try await Web3.InfuraMainnetWeb3(accessToken: optionalInfuraToken)
try await Web3.InfuraGoerliWeb3(accessToken: optionalInfuraToken)
```

If you have a URL or you are using Infura you can use the following:
```swift
try await Web3.new(url, network: chainIdHere)
// or
let web3 = try await Web3.InfuraMainnetWeb3(accessToken: optionalInfuraToken)
let web3 = try await Web3.InfuraGoerliWeb3(accessToken: optionalGoerliToken)
```

### Send Ether
```swift
let transaction: CodableTransaction = .emptyTransaction
transaction.from = from ?? transaction.sender // `sender` one is if you have private key of your wallet address, so public key e.g. your wallet address could be interpreted
transaction.value = value
transaction.gasLimitPolicy = .manual(78423)
transaction.gasPricePolicy = .manual(20000000000)
web3.eth.send(transaction)
```

### Contract read method
```swift
let contract = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress!)!
let readOp = contract.createReadOperation("name")!
readOp.transaction.from = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
let response = try await readTX.call()
```

### Write Transaction and call smart contract method
```swift
let abiString = "[]" // some ABI string
let bytecode = Data.fromHex("") // some ABI bite sequence
let contract = web3.contract(abiString, at: nil, abiVersion: 2)!
let parameters: [Any] = [...]
let deployOp = contract.prepareDeploy(bytecode: bytecode, constructor: contract.contract.constructor, parameters: parameters)!
deployOp.transaction.from = "" // your address
deployOp.transaction.gasLimitPolicy = .manual(3000000)
let result = try await deployTx.writeToChain(password: "web3swift")
```

### Sending network request to a node
```swift
func feeHistory(blockCount: UInt, block: BlockNumber, percentiles:[Double]) async throws -> Web3.Oracle.FeeHistory {
    let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
    let response: APIResponse<Web3.Oracle.FeeHistory> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall) /// explicitly declaring `Result` type is **required**.
    return response.result
}
```

## Build from source
### SPM
```bash
git clone https://github.com/web3swift-team/web3swift.git
cd web3swift
swift build
```

## Requirements
- iOS 13.0 / macOS 10.15
- Xcode 12.5
- Swift 5.5

## Documentation
Documentation is under construction👷🏻👷🏼‍♀️. We’re trying our best to comment on all public APIs as detailed as possible, but the end is still far to come. But in one of the nearest minor updates we’ll bring DocC support of already done amount of docs. And your PR in such are more than welcome.

## Projects that are using web3swift
Please take a look at [Our customers](https://github.com/web3swift-team/web3swift/wiki/Our-Customers) wiki page.

## Support

**[Join our discord](https://discord.gg/8bHCNmhS7x) and [Telegram](https://t.me/web3swift) if you need support or want to contribute to web3swift development!**

- If you **need help**, please take a look at our [FAQ](https://github.com/web3swift-team/web3swift/wiki/FAQ "") or [open an issue](https://github.com/web3swift-team/web3swift/issues).
- If you'd like to **see web3swift best practices**, check [Projects that using web3swift](https://github.com/web3swift-team/web3swift/wiki/Our-Customers).
- If you **found a bug**, [open an issue](https://github.com/web3swift-team/web3swift/issues).

## Development
To do local development and run the local tests, we recommend using [ganache](https://github.com/trufflesuite/ganache) which is also used by CI when running GitHub actions.

```cli
// To install
$ npm install ganache --global

// To run
$ ganache
```

This will create a local blockchain and also some test accounts that are used throughout our tests.
Make sure that `ganache` is running on its default port `8546`. To change the port in test cases locate `LocalTestCase.swift` and modify the static `url` variable.

### Before you commit

We are using [pre-commit](https://pre-commit.com) to run validations locally before a commit is created. Please, install pre-commit and run `pre-commit install` from the project's root directory. After that before every commit git hook will run and execute `codespell`, `swiftlint` and other checks.

## Contribute
Want to improve? It's awesome:
The good news for you: **We are ready to pay for your contribution via [@gitcoin bot](https://gitcoin.co/grants/358/web3swift)!**

- If you **have a feature request**, [open an issue](https://github.com/web3swift-team/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/web3swift-team/web3swift/pulls).

### Contribution
1. You are more than welcome to participate and get a bounty by contributing! **Your contribution will be paid via  [@gitcoin Grant program](https://gitcoin.co/grants/358/web3swift).**
2. Find or create an [issue](https://github.com/web3swift-team/web3swift/issues)
3. You can find open bounties in [Gitcoin Bounties](https://gitcoin.co/explorer?applicants=ALL&keywords=web3swift&order_by=-web3_created) list
4. Commita fix or a new feature in a branch, push your changes
5. [Submit a pull request to **develop** branch](https://github.com/web3swift-team/web3swift/pulls)
	1. Please, provide a detailed description of it to help us proceed faster.

[@skywinder](https://github.com/skywinder) are charged with open-sourсe and do not require money to use the web3swift library.
We want to continue to do everything we can to move the needle forward.

- **Support us** via [@gitcoin Grant program](https://gitcoin.co/grants/358/web3swift)
- Ether wallet address: `0x6A3738c6299f45c31697aceA647D49EdCC9C28A4`

<img src="https://raw.githubusercontent.com/skywinder/web3swift/develop/img/Ether-donations.jpeg" width="300" />

## Credits

- Alex Vlasov, [@shamatar](https://github.com/shamatar) - for the initial implementation
- Petr Korolev, [@skywinder](https://github.com/skywinder) - bootstrap and continuous support
- Anton Grigorev, [@baldyash](https://github.com/BaldyAsh) - core contributor, who use it and making a lot of improvements
- Yaroslav Yashin [@yaroslavyaroslav](https://github.com/yaroslavyaroslav) - core contributor of 3.0.0 and later releases.
- Thanks to [web3swift's growing list of contributors](https://github.com/web3swift-team/web3swift/graphs/contributors).

## Security Disclosure

If you believe you have identified a security vulnerability with web3swift, you should report it as soon as possible via email to [web3swift@oxor.io](mailto:web3swift@oxor.io). Please do not post it to a public issue tracker.

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/web3swift-team/web3swift/blob/master/LICENSE.md) for details.
