# Change Log

## [Unreleased](https://github.com/bankex/web3swift/tree/HEAD)

[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.4...HEAD)

**Merged pull requests:**

- Tests refactoring [\#61](https://github.com/BANKEX/web3swift/pull/61) ([skywinder](https://github.com/skywinder))

## [0.5.4](https://github.com/bankex/web3swift/tree/0.5.4) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.3...0.5.4)

**Merged pull requests:**

- fix regression of abi encoding [\#60](https://github.com/BANKEX/web3swift/pull/60) ([shamatar](https://github.com/shamatar))

## [0.5.3](https://github.com/bankex/web3swift/tree/0.5.3) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.2...0.5.3)

**Implemented enhancements:**

- how to create Mnemonic account with five level derivation path like M/44'/60'/0'/0/1 [\#42](https://github.com/BANKEX/web3swift/issues/42)

**Merged pull requests:**

- Wider range of parameter types as input to ABI encoder [\#59](https://github.com/BANKEX/web3swift/pull/59) ([shamatar](https://github.com/shamatar))

## [0.5.2](https://github.com/bankex/web3swift/tree/0.5.2) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.1...0.5.2)

**Fixed bugs:**

- Signing identical transaction results in different raw tx [\#53](https://github.com/BANKEX/web3swift/issues/53)
- I can not use my contract ? [\#43](https://github.com/BANKEX/web3swift/issues/43)
- Use of unresolved identifier 'EthereumAddress' [\#14](https://github.com/BANKEX/web3swift/issues/14)

**Closed issues:**

- the method " web3.eth.getBlockByNumber\(\)" reseult  fail? [\#54](https://github.com/BANKEX/web3swift/issues/54)
- the method"web3Main?.eth.getBalance\(\)" result is not correct? [\#50](https://github.com/BANKEX/web3swift/issues/50)
- Trying to create archive with web3swift [\#15](https://github.com/BANKEX/web3swift/issues/15)
- Documentation, samples, comments [\#13](https://github.com/BANKEX/web3swift/issues/13)
- Signing and unsigning. [\#52](https://github.com/BANKEX/web3swift/issues/52)

**Merged pull requests:**

- add ECrecover, personal sign and unlock account methods [\#58](https://github.com/BANKEX/web3swift/pull/58) ([shamatar](https://github.com/shamatar))
- Refactor secp256k1 part Slightly update an example Start working on web3.personal [\#56](https://github.com/BANKEX/web3swift/pull/56) ([shamatar](https://github.com/shamatar))
- fix regression [\#55](https://github.com/BANKEX/web3swift/pull/55) ([shamatar](https://github.com/shamatar))
- fix balance, provide better transaction receipt [\#51](https://github.com/BANKEX/web3swift/pull/51) ([shamatar](https://github.com/shamatar))

## [0.5.1](https://github.com/bankex/web3swift/tree/0.5.1) (2018-04-11)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.0...0.5.1)

**Merged pull requests:**

- bump podspec and release 0.5.1 [\#49](https://github.com/BANKEX/web3swift/pull/49) ([shamatar](https://github.com/shamatar))
- Contract deployment implementation [\#48](https://github.com/BANKEX/web3swift/pull/48) ([shamatar](https://github.com/shamatar))

## [0.5.0](https://github.com/bankex/web3swift/tree/0.5.0) (2018-04-10)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.4.1...0.5.0)

**Implemented enhancements:**

- Support returning structs from functions [\#33](https://github.com/BANKEX/web3swift/issues/33)

**Merged pull requests:**

- merge 0.5.0 [\#47](https://github.com/BANKEX/web3swift/pull/47) ([shamatar](https://github.com/shamatar))
- cleanup to prevent Pod from panicking [\#45](https://github.com/BANKEX/web3swift/pull/45) ([shamatar](https://github.com/shamatar))
- Fixes for external node work and more flexibility for BIP32 childs derivation [\#44](https://github.com/BANKEX/web3swift/pull/44) ([shamatar](https://github.com/shamatar))

## [0.4.1](https://github.com/bankex/web3swift/tree/0.4.1) (2018-04-07)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.4.0...0.4.1)

**Implemented enhancements:**

- Password for every transaction [\#16](https://github.com/BANKEX/web3swift/issues/16)
- Concurrent batched requests [\#38](https://github.com/BANKEX/web3swift/pull/38) ([skywinder](https://github.com/skywinder))

**Closed issues:**

- there is some error in example [\#27](https://github.com/BANKEX/web3swift/issues/27)
- EthereumKeystoreV3 constructor with KeystoreParamsV3 [\#17](https://github.com/BANKEX/web3swift/issues/17)
- Example and Code are different [\#9](https://github.com/BANKEX/web3swift/issues/9)

**Merged pull requests:**

- ABIv2 encoder now also works. Tested for most of the types, including string\[2\] and string\[\] [\#41](https://github.com/BANKEX/web3swift/pull/41) ([shamatar](https://github.com/shamatar))
- Tested ABIv2 parser, with no regressions [\#40](https://github.com/BANKEX/web3swift/pull/40) ([shamatar](https://github.com/shamatar))
- Streamlined concurrency, generic operations and fanout|join are available [\#39](https://github.com/BANKEX/web3swift/pull/39) ([shamatar](https://github.com/shamatar))

## [0.4.0](https://github.com/bankex/web3swift/tree/0.4.0) (2018-04-04)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.6...0.4.0)

**Implemented enhancements:**

- Struct encoder/decoder: Using a struct in a public function with ABIEncoderV2 [\#32](https://github.com/BANKEX/web3swift/issues/32)

**Closed issues:**

- BIP32Keystore and EthereumKeystoreV3 can't  getPrivateKeyData [\#28](https://github.com/BANKEX/web3swift/issues/28)

**Merged pull requests:**

- ABIEncoderV2 implementation [\#34](https://github.com/BANKEX/web3swift/pull/34) ([shamatar](https://github.com/shamatar))

## [0.3.6](https://github.com/bankex/web3swift/tree/0.3.6) (2018-04-02)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.5...0.3.6)

## [0.3.5](https://github.com/bankex/web3swift/tree/0.3.5) (2018-03-20)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.4...0.3.5)

**Implemented enhancements:**

- KeyStoreManger has only one constructor  [\#20](https://github.com/BANKEX/web3swift/issues/20)

**Closed issues:**

- web3contract send function incorrect error [\#25](https://github.com/BANKEX/web3swift/issues/25)
- Develop branch 404 [\#24](https://github.com/BANKEX/web3swift/issues/24)
- AbiElement.decodeReturnData supports only dynamicTypes [\#23](https://github.com/BANKEX/web3swift/issues/23)

## [0.3.4](https://github.com/bankex/web3swift/tree/0.3.4) (2018-03-18)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.3...0.3.4)

## [0.3.3](https://github.com/bankex/web3swift/tree/0.3.3) (2018-03-05)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.2...0.3.3)

## [0.3.2](https://github.com/bankex/web3swift/tree/0.3.2) (2018-03-03)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.1...0.3.2)

**Closed issues:**

- Signing transaction without connecting to web3 provider [\#22](https://github.com/BANKEX/web3swift/issues/22)
- Transaction Receipt [\#21](https://github.com/BANKEX/web3swift/issues/21)

## [0.3.1](https://github.com/bankex/web3swift/tree/0.3.1) (2018-03-01)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/bankex/web3swift/tree/0.3.0) (2018-02-27)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.99...0.3.0)

## [0.2.99](https://github.com/bankex/web3swift/tree/0.2.99) (2018-02-27)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.98...0.2.99)

**Closed issues:**

- Problem with signing/sending transactions [\#8](https://github.com/BANKEX/web3swift/issues/8)

## [0.2.98](https://github.com/bankex/web3swift/tree/0.2.98) (2018-02-27)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.12...0.2.98)

**Closed issues:**

- Method eth\_getAccounts not supported [\#7](https://github.com/BANKEX/web3swift/issues/7)
- Would crash when trying to parse my abi data [\#6](https://github.com/BANKEX/web3swift/issues/6)
- Web3 Provider [\#5](https://github.com/BANKEX/web3swift/issues/5)
- Creating a new keystore using mnemonics [\#4](https://github.com/BANKEX/web3swift/issues/4)

**Merged pull requests:**

- Add support for macOS [\#10](https://github.com/BANKEX/web3swift/pull/10) ([dsemenovsky](https://github.com/dsemenovsky))

## [0.2.12](https://github.com/bankex/web3swift/tree/0.2.12) (2018-02-01)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.11...0.2.12)

## [0.2.11](https://github.com/bankex/web3swift/tree/0.2.11) (2018-02-01)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.10...0.2.11)

## [0.2.10](https://github.com/bankex/web3swift/tree/0.2.10) (2018-01-31)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.9...0.2.10)

**Closed issues:**

- How to pass parameters to Contract Method? [\#3](https://github.com/BANKEX/web3swift/issues/3)

## [0.2.9](https://github.com/bankex/web3swift/tree/0.2.9) (2018-01-29)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.8...0.2.9)

**Closed issues:**

- Wrong conversation of the Wei. [\#2](https://github.com/BANKEX/web3swift/issues/2)
- How to connect to a Localhost Node? [\#1](https://github.com/BANKEX/web3swift/issues/1)

## [0.2.8](https://github.com/bankex/web3swift/tree/0.2.8) (2018-01-18)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.7...0.2.8)

## [0.2.7](https://github.com/bankex/web3swift/tree/0.2.7) (2018-01-15)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.5...0.2.7)

## [0.2.5](https://github.com/bankex/web3swift/tree/0.2.5) (2018-01-12)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.2.0...0.2.5)

## [0.2.0](https://github.com/bankex/web3swift/tree/0.2.0) (2017-12-30)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.1.2...0.2.0)

## [0.1.2](https://github.com/bankex/web3swift/tree/0.1.2) (2017-12-27)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/bankex/web3swift/tree/0.1.1) (2017-12-26)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/bankex/web3swift/tree/0.1.0) (2017-12-26)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.6...0.1.0)

## [0.0.6](https://github.com/bankex/web3swift/tree/0.0.6) (2017-12-26)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.5...0.0.6)

## [0.0.5](https://github.com/bankex/web3swift/tree/0.0.5) (2017-12-21)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.4...0.0.5)

## [0.0.4](https://github.com/bankex/web3swift/tree/0.0.4) (2017-12-21)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.3...0.0.4)

## [0.0.3](https://github.com/bankex/web3swift/tree/0.0.3) (2017-12-20)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/bankex/web3swift/tree/0.0.2) (2017-12-20)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/bankex/web3swift/tree/0.0.1) (2017-12-19)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*