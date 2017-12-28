![bkx-foundation-github-swift](https://user-images.githubusercontent.com/3356474/34412791-5b58962c-ebf0-11e7-8460-5592b12e6e9d.png)

# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)

# Functionality

- Send transactions, call functions of smart-contracts, estimate gas costs
- Serialize and deserialize transactions and results to native Swift types
- Convenience functions for chain state: block number, gas price
- Check transaction results and get receipt
- Parse event logs for transaction

## Example

To run the example project, clone the repo, and run `pod install` from the Example/web3swiftExample directory first.

## Requirements

Web3swift requires Swift 4.0 and internally depends from pods that require Swift 4.0 (CryptoSwift).

Internally depends from libsodium, CryptoSwift, Alamofire, PromiseKit and AwaitKit. Promise wrappers will be separated in further releases. Special thanks for Gnosis team and their library [Bivrost-swift](https://github.com/gnosis/bivrost-swift) for inspiration for the ABI decoding approach.

## Installation

web3swift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'web3swift'
```

## Global plans
- Full reference `web3js` functionality
- Light Ethereum subprotocol (LES) integration

## Appreciation

When using this pod references to this repo, [Bankex](http://bankex.com) and [Bankex Foundation](http://bankexfoundation.org) are appreciated.

## Authors

Alex Vlasov, @shamatar,  av@bankexfoundation.org

Petr Korolev, @skywinder, pk@bankexfoundation.org

## License

web3swift is available under the Apache License 2.0 license. See the LICENSE file for more info.
