# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)

# Functionality

- Send transactions, call functions of smart-contracts, estimate gas costs
- Serialize and deserialize transactions and results to native Swift types
- Convenience functions for chain state: block number, gas price
- Check transaction results and get receipt
- WIP: Parse event logs for transaction

## Example

To run the example project, clone the repo, and run `pod install` from the Example/web3swiftExample directory first.

## Requirements

Internally depends from libsodium, CryptoSwift, Alamofire, PromiseKit and AwaitKit. Promise wrappers will be separated in further releases.

## Installation

web3swift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'web3swift'
```

## Appreciation

When using this pod references to this repo, [Bankex](http://bankex.com) and [Bankex Foundation](http://bankexfoundation.org) are appreciated.

## Author

Alex Vlasov, @shamatar,  av@bankexfoundation.org
Petr Korolev, @skywinder, pk@bankexfoundation.org

## License

web3swift is available under the MIT license. See the LICENSE file for more info.