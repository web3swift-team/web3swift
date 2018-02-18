![bkx-foundation-github-swift](https://user-images.githubusercontent.com/3356474/34412791-5b58962c-ebf0-11e7-8460-5592b12e6e9d.png)

# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)

- Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- Interaction with remote node via JSON RPC :thought_balloon:
- Smart-contract ABI parsing :book:
  - ABI deconding 
  - RLP encoding
- Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- Local keystore management (geth compatible)
- Literally following the standarts:
  - [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
  - [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
  - [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
  - [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *enforced!*


## Check this out

- Private key and transaction were created directly on the iOS device and sent directly to [Infura](https://infura.io) node.
- Native API
- Security (as cool as hard wallet! Right out-of-the-box! :box:)

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

### Requirements

Web3swift requires Swift 4.0 and iOS 9.0 (although we strongly recommend to always use the latest iOS version for your security).


### Installation

web3swift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'web3swift'
```
### Current functionality

- Send transactions, call functions of smart-contracts, estimate gas costs
- Serialize and deserialize transactions and results to native Swift types
- Convenience functions for chain state: block number, gas price
- Check transaction results and get receipt
- Parse event logs for transaction

### Global plans
- Full reference `web3js` functionality
- Light Ethereum subprotocol (LES) integration

## Special thanks to 

- Gnosis team and their library [Bivrost-swift](https://github.com/gnosis/bivrost-swift) for inspiration for the ABI decoding approach
- [Trust iOS Wallet](https://github.com/TrustWallet/trust-wallet-ios) for collaboration and discussion for initial idea

## Contribution

For the latest version, please check [develop](https://github.com/BANKEX/web3swift/tree/develop) branch. 
Changes from this branch will be merged into the [master](https://github.com/BANKEX/web3swift/tree/master) branch at some point.

- If you want to contribute, submit a [pull request](https://github.com/BANKEX/web3swift/pulls) against a development `develop` branch.
- If you found a bug, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you have a feature request, [open an issue](https://github.com/BANKEX/web3swift/issues).


## Appreciation

When using this pod references to this repo, [Bankex](http://bankex.com) and [Bankex Foundation](http://bankexfoundation.org) are appreciated.

## Authors

Alex Vlasov, [@shamatar](https://github.com/shamatar),  av@bankexfoundation.org

Petr Korolev, [@skywinder](https://github.com/skywinder), pk@bankexfoundation.org

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/BankEx/web3swift/blob/master/LICENSE) file for more info.
