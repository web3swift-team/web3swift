# Change Log

## [Unreleased](https://github.com/matterinc/web3swift/tree/HEAD)

[Full Changelog](https://github.com/matterinc/web3swift/compare/1.5.1...HEAD)

**Implemented enhancements:**

- ENS for wallets [\#12](https://github.com/matterinc/web3swift/issues/12)
- Recover passphrase from BIP32 store [\#5](https://github.com/matterinc/web3swift/issues/5)

**Merged pull requests:**

- hotfix update pods [\#71](https://github.com/matterinc/web3swift/pull/71) ([BaldyAsh](https://github.com/BaldyAsh))

## [1.5.1](https://github.com/matterinc/web3swift/tree/1.5.1) (2018-10-22)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.5...1.5.1)

**Merged pull requests:**

- Function visibility fix [\#70](https://github.com/matterinc/web3swift/pull/70) ([shamatar](https://github.com/shamatar))

## [1.5](https://github.com/matterinc/web3swift/tree/1.5) (2018-10-18)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.1.10...1.5)

**Implemented enhancements:**

- Can you add support for ERC-721 tokens [\#7](https://github.com/matterinc/web3swift/issues/7)

**Closed issues:**

- Creating a new wallet is too slow [\#63](https://github.com/matterinc/web3swift/issues/63)
- need to update for Xcode10 [\#49](https://github.com/matterinc/web3swift/issues/49)
- Web3.Utils.formatToEthereumUnits  [\#48](https://github.com/matterinc/web3swift/issues/48)
- Interface ideas are welcome for v2.0 [\#3](https://github.com/matterinc/web3swift/issues/3)

**Merged pull requests:**

- Add TxPool and ERC721 native class [\#68](https://github.com/matterinc/web3swift/pull/68) ([shamatar](https://github.com/shamatar))
- Feature/erc721 [\#67](https://github.com/matterinc/web3swift/pull/67) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/adding logo [\#66](https://github.com/matterinc/web3swift/pull/66) ([BaldyAsh](https://github.com/BaldyAsh))
- adds txpool function and its local node test [\#64](https://github.com/matterinc/web3swift/pull/64) ([currybab](https://github.com/currybab))
- License got reverted somewhere after PRs [\#60](https://github.com/matterinc/web3swift/pull/60) ([shamatar](https://github.com/shamatar))

## [1.1.10](https://github.com/matterinc/web3swift/tree/1.1.10) (2018-10-04)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.1.9...1.1.10)

**Merged pull requests:**

- Preliminary ENS support, start module splitting [\#59](https://github.com/matterinc/web3swift/pull/59) ([shamatar](https://github.com/shamatar))
- Feature/readme improvement [\#55](https://github.com/matterinc/web3swift/pull/55) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/support obj c [\#54](https://github.com/matterinc/web3swift/pull/54) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/ENSsupport [\#53](https://github.com/matterinc/web3swift/pull/53) ([FesenkoG](https://github.com/FesenkoG))
- Add Travis configuration [\#52](https://github.com/matterinc/web3swift/pull/52) ([skywinder](https://github.com/skywinder))
- Added ERC-20 token for testing web3swift lib [\#50](https://github.com/matterinc/web3swift/pull/50) ([BaldyAsh](https://github.com/BaldyAsh))

## [1.1.9](https://github.com/matterinc/web3swift/tree/1.1.9) (2018-09-18)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.1.7...1.1.9)

**Fixed bugs:**

- eth.getAccounts\(\) function returns an empty address Array [\#24](https://github.com/matterinc/web3swift/issues/24)
- EIP681 bug fixes, accessibility in Function changed [\#35](https://github.com/matterinc/web3swift/pull/35) ([FesenkoG](https://github.com/FesenkoG))

**Closed issues:**

- the version 1.1.6 couldn't from password and keystore to  get the privateKey [\#32](https://github.com/matterinc/web3swift/issues/32)
- Need implementation of EIP-681 parsing  [\#25](https://github.com/matterinc/web3swift/issues/25)

**Merged pull requests:**

- Update for XCode 10 [\#39](https://github.com/matterinc/web3swift/pull/39) ([shamatar](https://github.com/shamatar))
- Basic ENS support added, EIP681 parsing supports ENS from now. [\#38](https://github.com/matterinc/web3swift/pull/38) ([FesenkoG](https://github.com/FesenkoG))

## [1.1.7](https://github.com/matterinc/web3swift/tree/1.1.7) (2018-09-13)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.1.6...1.1.7)

**Fixed bugs:**

- Thread blocked [\#16](https://github.com/matterinc/web3swift/issues/16)

**Closed issues:**

- How to create same address and keystore by mnemonics? [\#22](https://github.com/matterinc/web3swift/issues/22)

**Merged pull requests:**

- Fix ethereum address parsing, add readme [\#34](https://github.com/matterinc/web3swift/pull/34) ([shamatar](https://github.com/shamatar))
- complete EIP681, fix the most stupid Ethereum address parsing [\#33](https://github.com/matterinc/web3swift/pull/33) ([shamatar](https://github.com/shamatar))
- Add examples to readme, prettify formatting [\#31](https://github.com/matterinc/web3swift/pull/31) ([skywinder](https://github.com/skywinder))
- continue eip681 work [\#27](https://github.com/matterinc/web3swift/pull/27) ([shamatar](https://github.com/shamatar))
- Implement EIP681 parser \(untested\) [\#26](https://github.com/matterinc/web3swift/pull/26) ([shamatar](https://github.com/shamatar))
- Change access control of function fromRaw in struct EthereumTransaction [\#11](https://github.com/matterinc/web3swift/pull/11) ([Plazmathron](https://github.com/Plazmathron))

## [1.1.6](https://github.com/matterinc/web3swift/tree/1.1.6) (2018-09-04)
[Full Changelog](https://github.com/matterinc/web3swift/compare/1.1.5...1.1.6)

**Merged pull requests:**

- Quick fix for scrypt performance [\#17](https://github.com/matterinc/web3swift/pull/17) ([shamatar](https://github.com/shamatar))
- adding description string to Web3Error [\#1](https://github.com/matterinc/web3swift/pull/1) ([GabCas](https://github.com/GabCas))

[Full Changelog](https://github.com/bankex/web3swift/compare/0.6.0...HEAD)

**Closed issues:**

- Transaction or options are malformed in Token Transfer [\#78](https://github.com/BANKEX/web3swift/issues/78)
- Error when install [\#75](https://github.com/BANKEX/web3swift/issues/75)

**Merged pull requests:**

- update podspec and readme [\#82](https://github.com/BANKEX/web3swift/pull/82) ([shamatar](https://github.com/shamatar))

## [0.6.0](https://github.com/bankex/web3swift/tree/0.6.0) (2018-04-24)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.6...0.6.0)

**Closed issues:**

- InValid Account Error [\#76](https://github.com/BANKEX/web3swift/issues/76)

**Merged pull requests:**

- add example of ERC20 transfer in Example [\#81](https://github.com/BANKEX/web3swift/pull/81) ([shamatar](https://github.com/shamatar))
- include example of ERC20 token transfer [\#80](https://github.com/BANKEX/web3swift/pull/80) ([shamatar](https://github.com/shamatar))
- Allow BIP32 keystore init from seed directly Add convenience BIP32 keystore and KeystoreV3 serialization methods Test custom path derivation after saving Add new BIP39 languages [\#74](https://github.com/BANKEX/web3swift/pull/74) ([shamatar](https://github.com/shamatar))

## [0.5.6](https://github.com/bankex/web3swift/tree/0.5.6) (2018-04-20)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.5...0.5.6)

**Fixed bugs:**

- Crash when generate keystore by mnemonics [\#62](https://github.com/BANKEX/web3swift/issues/62)

**Closed issues:**

- BIP39 Keystore not accessible from keystore parameter path [\#68](https://github.com/BANKEX/web3swift/issues/68)

**Merged pull requests:**

- convenience methods in web3.eth to send ETH using either raw BigUInt value in Wei, or parsing a decimal string of arbitrary units [\#72](https://github.com/BANKEX/web3swift/pull/72) ([shamatar](https://github.com/shamatar))
- improve BIP32 serialization to disk [\#71](https://github.com/BANKEX/web3swift/pull/71) ([shamatar](https://github.com/shamatar))
- Fix BIP32 keystore when used through Manager [\#70](https://github.com/BANKEX/web3swift/pull/70) ([shamatar](https://github.com/shamatar))
- add marshalling and unmarshalling signature as a part of Web3.Utils [\#69](https://github.com/BANKEX/web3swift/pull/69) ([shamatar](https://github.com/shamatar))
- Event parsing example from user case [\#67](https://github.com/BANKEX/web3swift/pull/67) ([shamatar](https://github.com/shamatar))

## [0.5.5](https://github.com/bankex/web3swift/tree/0.5.5) (2018-04-18)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.4...0.5.5)

**Closed issues:**

- Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value [\#57](https://github.com/BANKEX/web3swift/issues/57)

**Merged pull requests:**

- Solidity bound ECRecover test and example [\#66](https://github.com/BANKEX/web3swift/pull/66) ([shamatar](https://github.com/shamatar))
- Fix BIP 32 derivation in release build \(with optimization\) [\#65](https://github.com/BANKEX/web3swift/pull/65) ([shamatar](https://github.com/shamatar))
- Tests refactoring [\#61](https://github.com/BANKEX/web3swift/pull/61) ([skywinder](https://github.com/skywinder))

## [0.5.4](https://github.com/bankex/web3swift/tree/0.5.4) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.3...0.5.4)

**Merged pull requests:**

- fix regression of abi encoding [\#60](https://github.com/BANKEX/web3swift/pull/60) ([shamatar](https://github.com/shamatar))

## [0.5.3](https://github.com/bankex/web3swift/tree/0.5.3) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.2...0.5.3)

**Merged pull requests:**

- Wider range of parameter types as input to ABI encoder [\#59](https://github.com/BANKEX/web3swift/pull/59) ([shamatar](https://github.com/shamatar))

## [0.5.2](https://github.com/bankex/web3swift/tree/0.5.2) (2018-04-16)
[Full Changelog](https://github.com/bankex/web3swift/compare/0.5.1...0.5.2)

**Implemented enhancements:**

- Signing and unsigning. [\#52](https://github.com/BANKEX/web3swift/issues/52)

**Fixed bugs:**

- Signing identical transaction results in different raw tx [\#53](https://github.com/BANKEX/web3swift/issues/53)
- I can not use my contract ? [\#43](https://github.com/BANKEX/web3swift/issues/43)
- Use of unresolved identifier 'EthereumAddress' [\#14](https://github.com/BANKEX/web3swift/issues/14)

**Closed issues:**

- the method " web3.eth.getBlockByNumber\(\)" reseult  fail? [\#54](https://github.com/BANKEX/web3swift/issues/54)
- the method"web3Main?.eth.getBalance\(\)" result is not correct? [\#50](https://github.com/BANKEX/web3swift/issues/50)
- Documentation, samples, comments [\#13](https://github.com/BANKEX/web3swift/issues/13)

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
- Mnemonic account with five level derivation path like M/44'/60'/0'/0/1 [\#42](https://github.com/BANKEX/web3swift/issues/42)

**Fixed bugs:**

- Build error during archiving web3swift [\#15](https://github.com/BANKEX/web3swift/issues/15)

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



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*