![bkx-foundation-github-swift](https://user-images.githubusercontent.com/3356474/34412791-5b58962c-ebf0-11e7-8460-5592b12e6e9d.png)

## Important notices
With the version 0.3.0 API should be less volatile. All public functions should return a [Result](https://github.com/antitypical/Result) instead of `nil` or throwing.

Example is updated for 0.5.0, although please prefer to use tests as an example for your code.

# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0x6394b37Cf80A7358b38068f0CA4760ad49983a1B)

- Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- Interaction with remote node via JSON RPC :thought_balloon:
- Smart-contract ABI parsing :book:
  - ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
  - RLP encoding
- Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- Local keystore management (geth compatible)
- Literally following the standarts:
  - [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
  - [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
  - [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
  - [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *enforced!*


## Check this out

- Private key and transaction were created directly on the iOS device and sent directly to [Infura](https://infura.io) node
- Native API
- Security (as cool as hard wallet! Right out-of-the-box! :box: )

## Design decisions

- Not every JSON RPC function is exposed yet, priority is gives to ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on device to send raw transaction to Ethereum network
- Requirements for password input on every transactions are indeed a design decision. Interface designers can save user passwords given user's consent
- Public function for private key export is exposed for user convenience, but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

### Here it is
[https://rinkeby.etherscan.io/tx/0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056](https://rinkeby.etherscan.io/tx/0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056)

```
Transaction
Nonce: 35
Gas price: 5000000000
Gas limit: 21000
To: 0x6394b37Cf80A7358b38068f0CA4760ad49983a1B
Value: 1000000000000000
Data: 0x
v: 43
r: 73059897783840535708732471549376620878882680550447969052675399628060606060727
s: 12280625377431973240236065453692843538037349746280474092545114784968542260859
Intrinsic chainID: Optional(4)
Infered chainID: Optional(4)
sender: Optional(web3swift.EthereumAddress(_address: "0x855adf524273c14b7260a188af0ae30e82e91959"))

["id": 1514485925, "result": 0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056, "jsonrpc": 2.0]
On Rinkeby TXid = 0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056
```

## Example

You can try it by yourself by running the example project:

- Clone the repo
- `cd Example/web3swiftExample`
- run `pod install` from the `Example/web3swiftExample` directory.
- `open ./web3swiftExample.xcworkspace`

## Requirements

Web3swift requires Swift 4.1 and iOS 9.0 or macOS 10.13 although we recommend to use the latest iOS and MacOS versions for your own safety. Don't forget to set iOS version in a Podfile, otherwise you get an error if deployment target is less than the latest SDK.

## Communication

- if you **need help**, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift) (tag 'web3swift')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/web3swift).
- If you **found a bug**, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you **have a feature request**, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/BANKEX/web3swift/pulls).

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
    pod 'web3swift', :git => 'https://github.com/BANKEX/web3swift.git'
end
```

Then, run the following command:

```bash
$ pod install
```
## Features

- [x] Create Account
- [x] Import Account
- [x] Sign transictions
- [x] Send transactions, call functions of smart-contracts, estimate gas costs
- [x] Serialize and deserialize transactions and results to native Swift types
- [x] Convenience functions for chain state: block number, gas price
- [x] Check transaction results and get receipt
- [x] Parse event logs for transaction
- [x] Manage user's private keys through encrypted keystore abstractions
- [x] Batched requests in concurrent mode, checks balances of 580 tokens (from the latest MyEtherWallet repo) over 3 seconds

## Usage

Here you can see a few examples of use of our library
### Initializing Ethereum address
```bash
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
let constractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
```

### Getting gas price
```bash
let web3Main = Web3.InfuraMainnetWeb3()
let gasPriceResult = web3Main.eth.getGasPrice()
guard case .success(let gasPrice) = gasPriceResult else {return}
```
### Setting options
```bash
var options = Web3Options.defaultOptions()
options.gasPrice = gasPrice
options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")!
let parameters = [] as [AnyObject]
```

### Getting balance
```bash
guard let bkxBalanceResult = contract.method("balanceOf", parameters: [coldWalletAddress] as [AnyObject], options: options)?.call(options: nil) else {return}
guard case .success(let bkxBalance) = bkxBalanceResult, let bal = bkxBalance["0"] as? BigUInt else {return}
print("BKX token balance = " + String(bal))
```

### Sending ETH
```bash
let web3Rinkeby = Web3.InfuraRinkebyWeb3()

web3Rinkeby.addKeystoreManager(bip32keystoreManager)
options.from = bip32ks?.addresses?.first!
intermediateSend = web3Rinkeby.contract(coldWalletABI, at: coldWalletAddress, abiVersion: 2)!.method(options: options)!
let sendResultBip32 = intermediateSend.send(password: "BANKEXFOUNDATION")
switch sendResultBip32 {
    case .success(let r):
        print(r)
    case .failure(let err):
        print(err)
}
```

### Sending ERC20
```bash
var convenienceTransferOptions = Web3Options.defaultOptions()
convenienceTransferOptions.gasPrice = gasPriceRinkeby
let convenienceTokenTransfer = web3Rinkeby.eth.sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress("0xa407dd0cbc9f9d20cdbd557686625e586c85b20a")!, from: (ks?.addresses?.first!)!, to: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!, amount: "0.0001", options: convenienceTransferOptions)
let gasEstimateResult2 = convenienceTokenTransfer!.estimateGas(options: nil)
guard case .success(let gasEstimate2) = gasEstimateResult2 else {return}
convenienceTransferOptions.gasLimit = gasEstimate2
let convenienceTransferResult = convenienceTokenTransfer!.send(password: "BANKEXFOUNDATION", options: convenienceTransferOptions)
switch convenienceTransferResult {
    case .success(let res):
        print("Token transfer successful")
        print(res)
    case .failure(let error):
        print(error)
}
```

## Global plans
- Full reference `web3js` functionality
- Light Ethereum subprotocol (LES) integration

## [Apps using this library](https://github.com/BANKEX/web3swift/wiki/Apps-using-web3swift) 

If you've used this project in a live app, please let us know!

*If you are using `web3swift` in your app or know of an app that uses it, please add it to [this] (https://github.com/BANKEX/web3swift/wiki/Apps-using-web3swift) list.*

## Special thanks to

- Gnosis team and their library [Bivrost-swift](https://github.com/gnosis/bivrost-swift) for inspiration for the ABI decoding approach
- [Trust iOS Wallet](https://github.com/TrustWallet/trust-wallet-ios) for collaboration and discussion for initial idea
- Official Ethereum and Solidity docs, everything was written from ground truth standards

## Contribution

For the latest version, please check [develop](https://github.com/BANKEX/web3swift/tree/develop) branch.
Changes from this branch will be merged into the [master](https://github.com/BANKEX/web3swift/tree/master) branch at some point.

- If you want to contribute, submit a [pull request](https://github.com/BANKEX/web3swift/pulls) against a development `develop` branch.
- If you found a bug, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you have a feature request, [open an issue](https://github.com/BANKEX/web3swift/issues).


## Appreciation

When using this pod references to this repo, [BANKEX](http://bankex.com) and [BANKEX Foundation](http://bankexfoundation.org) are appreciated.

## Authors

Alex Vlasov, [@shamatar](https://github.com/shamatar),  av@bankexfoundation.org

Petr Korolev, [@skywinder](https://github.com/skywinder), pk@bankexfoundation.org

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/BankEx/web3swift/blob/master/LICENSE) file for more info.
