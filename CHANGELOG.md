# Changelog

## [2.6.5](https://github.com/skywinder/web3swift/tree/2.6.5) (2022-05-26)

- correct the decoding key for from in transactionOptions by @mloit in #570

## [2.6.4](https://github.com/skywinder/web3swift/tree/2.6.4) (2022-05-06)

- Fix ERC-1155 ABI by @mloit in #557
- Fix access level for EIP-712 related objects by @mloit in #555
- Restore public API fromJSON() functions by @mloit in #558

## [2.6.3](https://github.com/skywinder/web3swift/tree/2.6.3) (2022-04-27)

- Feature/automatic gas 1559 by @mloit in #547
- Oracle.suggestGasFeeLegacy method fixup by @yaroslavyaroslav in #551

## [2.6.2](https://github.com/skywinder/web3swift/tree/2.6.2) (2022-04-25)

- Fix #540 by freezing CryptoSwift dependency to last working version (1.4.3) by @yaroslavyaroslav

## [2.6.1](https://github.com/skywinder/web3swift/tree/2.6.1) (2022-04-19)

- Update documentation for EIP-1559 support by @mloit in #530
- Feature/transaction metadata by @mloit in #523

## [2.6.0](https://github.com/skywinder/web3swift/tree/2.6.0) (2022-04-15)

### Features

- Add full EIP-1559 transaction support see
- Add gas prediction support see

### What's Changed

- Remove BrowserViewController if building for anything other than iOS by @mloit in #503
- Feature/pre swiftlint cleanup by @mloit in #495
- Feature/late lint fixups by @mloit in #508
- Fix Base58 Decoding by @mloit in #504
- Swiftlint by @mloit in #499
- ERC1155: Change access control for Interfece-based methods. by @mrklos in #494
- feat: solidity sha3 implementation added by @JeneaVranceanu in #506
- add indentation check [default is 4 spaces per tab-stop] by @mloit in #512
- EIP-1559 support release by @yaroslavyaroslav in #510
- EIP-1559 Gas prediction implementation by @yaroslavyaroslav in #513
- feat: decoding ABI with solidity error types by @JeneaVranceanu in #455
- Gas prediction implementation by @yaroslavyaroslav in #514
- Bug fix/transaction index by @mloit in #521
- EIP-1559 transaction support by @mloit in #509
- Full Changelog: 2.5.1...2.6.0

## [2.5.1](https://github.com/skywinder/web3swift/tree/2.5.1) (2022-03-23)

- Drop Carthage cache files by yaroslavyaroslav
- Drop examples cocoapods cache files by yaroslavyaroslav
- Improve ci/cd pipeline by adding localTests job by yaroslavyaroslav
- Rename tests in swift style name convention (CamelCase) by yaroslavyaroslav
- Enable run ganache util in ci/cd pipeline (required for local tests) by yaroslavyaroslav
- Clear lib warnings on build #437 by Valter4578 & mliot
- Change UINT64_MAX to UInt64.max by mloit
- Update CHANGELOG.md by ZeroCode999
- Fix tokenURI method name for ERC721 and ERC721x tokens #419 by Sarquella
- Provide basic tolerance to EIP-1559 data by mloit
- Fix for buffer overflow in [Data|SECP256K1].randomBytes() #470 by mloit
- Arbitrary clean project code by mloit
- Fix github actions config issue that occasionally cancels running jobs by yaroslavyaroslav
- mini-rollup of several issues by mloit

## [2.5.0](https://github.com/skywinder/web3swift/tree/2.5.0) (2021-12-23)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.3.0...2.5.0)

**Implemented enhancements:**

- Add support of EIP-712 signatures [\#323](https://github.com/skywinder/web3swift/issues/323)
- BIP39.mnemonicsToEntropy does not work for mnemonics of length 15, 18, 21 [\#300](https://github.com/skywinder/web3swift/issues/300)
- Support Solidity 0.6 & ABIEncoderV2 [\#258](https://github.com/skywinder/web3swift/issues/258)
- Omit zeros at the end of formatted string [\#117](https://github.com/skywinder/web3swift/issues/117)
- \[recreated\] Detect read function aborting by messaged require statement [\#276](https://github.com/skywinder/web3swift/pull/276) ([hakumai-iida](https://github.com/hakumai-iida))

**Fixed bugs:**

- `subscribeOnLogs` method with specific contract address is not working!!!! [\#366](https://github.com/skywinder/web3swift/issues/366)
- EthereumContract with Custom ABI returns nil [\#342](https://github.com/skywinder/web3swift/issues/342)
- Error on running tests [\#290](https://github.com/skywinder/web3swift/issues/290)
- Serialisation of BIP32 misplaced address position [\#257](https://github.com/skywinder/web3swift/issues/257)
- Xcode 10.2.1 carthage update hangs while building web3swift.xcodeproj [\#197](https://github.com/skywinder/web3swift/issues/197)

**Closed issues:**

- Error in Documentation Examples: "Failed to fetch gas estimate" [\#421](https://github.com/skywinder/web3swift/issues/421)
- BSC Network Transaction [\#418](https://github.com/skywinder/web3swift/issues/418)
- How to sign and send ERC20 token [\#413](https://github.com/skywinder/web3swift/issues/413)
- Example [\#409](https://github.com/skywinder/web3swift/issues/409)
- How install for macOS? [\#408](https://github.com/skywinder/web3swift/issues/408)
- Use case for Web3Swift [\#405](https://github.com/skywinder/web3swift/issues/405)
- Make and example on how to use ENS domains [\#404](https://github.com/skywinder/web3swift/issues/404)
- Make an example on how to check your wallet balance [\#402](https://github.com/skywinder/web3swift/issues/402)
- Implement a functionality to add custom chains [\#401](https://github.com/skywinder/web3swift/issues/401)
- Prepare and example on how to use mnemonics [\#399](https://github.com/skywinder/web3swift/issues/399)
- Expired Discord invitation link [\#382](https://github.com/skywinder/web3swift/issues/382)
- How to estimate gas limit and gas price ? [\#380](https://github.com/skywinder/web3swift/issues/380)
- let block = try? web3.eth.getBlockNumber\(\) [\#376](https://github.com/skywinder/web3swift/issues/376)
- Support carthage  both M1 and Intel processors [\#375](https://github.com/skywinder/web3swift/issues/375)
- Support for Xcode 12 SPM [\#373](https://github.com/skywinder/web3swift/issues/373)
- promisekit: warning: `wait()` called on main thread!  [\#372](https://github.com/skywinder/web3swift/issues/372)
- How to generate web3swift framework file from source [\#369](https://github.com/skywinder/web3swift/issues/369)
- how to maintain multiple wallet ,need to store separate key json file? [\#367](https://github.com/skywinder/web3swift/issues/367)
- Extremely slow init BIP39 and keystore in current dev branch [\#365](https://github.com/skywinder/web3swift/issues/365)
- How can i get EventLogs and topics from a transaction response? [\#359](https://github.com/skywinder/web3swift/issues/359)
- Cannot parse ABI with tuple\[\] [\#358](https://github.com/skywinder/web3swift/issues/358)
- Send Transaction issue, processingError\(desc: "Failed to fetch gas estimate"\) [\#356](https://github.com/skywinder/web3swift/issues/356)
- Instance member 'contract' cannot be used on type 'web3'; did you mean to use a value of this type instead? [\#352](https://github.com/skywinder/web3swift/issues/352)
- Could not build Objective-C module 'web3swift' [\#344](https://github.com/skywinder/web3swift/issues/344)
- Building the latest web3Swift example [\#341](https://github.com/skywinder/web3swift/issues/341)
- cannot open https://exchange.pancakeswap.finance/\#/swap [\#338](https://github.com/skywinder/web3swift/issues/338)
- Crash with parsing custom ABI Contract [\#333](https://github.com/skywinder/web3swift/issues/333)
- @ravi-ranjan-oodles thanks for the update. [\#329](https://github.com/skywinder/web3swift/issues/329)
- Issue in Uploading to Test Flight  [\#328](https://github.com/skywinder/web3swift/issues/328)
- Update CryptoSwift podspec [\#322](https://github.com/skywinder/web3swift/issues/322)
- can't open DApp， such as "https://uniswap.tokenpocket.pro/\#/swap" [\#321](https://github.com/skywinder/web3swift/issues/321)
- CryptoSwift version is too low to work properly in Xcode12.5 [\#318](https://github.com/skywinder/web3swift/issues/318)
- web3swift.Web3Error.processingError\(desc: "Failed to fetch gas estimate"\)（BSC Chain） [\#317](https://github.com/skywinder/web3swift/issues/317)
- Quick simple steps for minting ERC20 or ERC721 tokens  [\#314](https://github.com/skywinder/web3swift/issues/314)
- Generate Contract Bytecode / Address [\#313](https://github.com/skywinder/web3swift/issues/313)
- I can't find func 'Web3.InfuraKovanWeb3\(\)' [\#311](https://github.com/skywinder/web3swift/issues/311)
- web3 instance error:  Variable used within its own initial value [\#310](https://github.com/skywinder/web3swift/issues/310)
- Failed to fetch gas estimate when sending erc20 [\#307](https://github.com/skywinder/web3swift/issues/307)
- DApp browser can't open Uniswap in a right way [\#304](https://github.com/skywinder/web3swift/issues/304)
- Update cocoapods bigint to 5.0 [\#288](https://github.com/skywinder/web3swift/issues/288)
- When I use getBlockByNumber  ,  hash Unable to check [\#287](https://github.com/skywinder/web3swift/issues/287)
- How to parse the return value of read transaction [\#284](https://github.com/skywinder/web3swift/issues/284)
- Failed to fetch gas estimate [\#283](https://github.com/skywinder/web3swift/issues/283)
- Generic parameter 'Element' could not be inferred [\#282](https://github.com/skywinder/web3swift/issues/282)
- Unable to send ether using send function [\#279](https://github.com/skywinder/web3swift/issues/279)
- This request is not supported because your node is running with state pruning. Run with --pruning=archive. [\#274](https://github.com/skywinder/web3swift/issues/274)
- Send   ERC20 token error And get token name error [\#262](https://github.com/skywinder/web3swift/issues/262)
- Problem when decoding raw transaction input data [\#216](https://github.com/skywinder/web3swift/issues/216)
- Is it necessary to use password in creating Bip32keystore ? [\#213](https://github.com/skywinder/web3swift/issues/213)

**Merged pull requests:**

- Fix-up [\#427](https://github.com/skywinder/web3swift/pull/427) ([yaroslavyaroslav](https://github.com/yaroslavyaroslav))
- 2.5.0 [\#426](https://github.com/skywinder/web3swift/pull/426) ([yaroslavyaroslav](https://github.com/yaroslavyaroslav))
- Bugfix: Derive PublicKey [\#423](https://github.com/skywinder/web3swift/pull/423) ([yuzhiyou1990](https://github.com/yuzhiyou1990))
- Enabling GitHub actions [\#422](https://github.com/skywinder/web3swift/pull/422) ([yaroslavyaroslav](https://github.com/yaroslavyaroslav))
- Fix building issue [\#410](https://github.com/skywinder/web3swift/pull/410) ([yaroslavyaroslav](https://github.com/yaroslavyaroslav))
- Fixed keystore backward compatibility [\#397](https://github.com/skywinder/web3swift/pull/397) ([BaldyAsh](https://github.com/BaldyAsh))
- add support of EIP-712 signature [\#396](https://github.com/skywinder/web3swift/pull/396) ([BaldyAsh](https://github.com/BaldyAsh))
- Fix ENS.getContentHash to return Data [\#395](https://github.com/skywinder/web3swift/pull/395) ([battlmonstr](https://github.com/battlmonstr))
- Fix Serialisation of BIP32 Keystore [\#394](https://github.com/skywinder/web3swift/pull/394) ([BaldyAsh](https://github.com/BaldyAsh))
- Dependency update | M1 support  [\#389](https://github.com/skywinder/web3swift/pull/389) ([Valter4578](https://github.com/Valter4578))
- Fixed typo in function name [\#386](https://github.com/skywinder/web3swift/pull/386) ([JeneaVranceanu](https://github.com/JeneaVranceanu))
- Updated Example and Updated Version for BigInt , CryptoSwift and PromiseKit dependency [\#383](https://github.com/skywinder/web3swift/pull/383) ([veerChauhan](https://github.com/veerChauhan))
- add support of EIP-712 signature [\#381](https://github.com/skywinder/web3swift/pull/381) ([AndreyMaksimkin](https://github.com/AndreyMaksimkin))
- fixed parsing of ABIs with tuples + wrong gas info when transactionOptions created from json [\#379](https://github.com/skywinder/web3swift/pull/379) ([izakpavel](https://github.com/izakpavel))
- fixed: websocket delegate issue \(new\) [\#378](https://github.com/skywinder/web3swift/pull/378) ([amirhossein7](https://github.com/amirhossein7))
- Added Promise: Support for getCode function [\#368](https://github.com/skywinder/web3swift/pull/368) ([SwiftyLimi](https://github.com/SwiftyLimi))
- Added: Receive type at ABI.Element [\#348](https://github.com/skywinder/web3swift/pull/348) ([SwiftyLimi](https://github.com/SwiftyLimi))
- Update local Tests and refactoring [\#347](https://github.com/skywinder/web3swift/pull/347) ([BaldyAsh](https://github.com/BaldyAsh))
- update carthage build scripts to support xcode 11-12 [\#345](https://github.com/skywinder/web3swift/pull/345) ([skywinder](https://github.com/skywinder))
- Update libs versions, Cartfile and Pods dependencies  [\#334](https://github.com/skywinder/web3swift/pull/334) ([AnnaYatsun1](https://github.com/AnnaYatsun1))
- fix crash when 'payable' nil [\#332](https://github.com/skywinder/web3swift/pull/332) ([xdozorx](https://github.com/xdozorx))
- Update README.md [\#331](https://github.com/skywinder/web3swift/pull/331) ([Iysbaera](https://github.com/Iysbaera))
- CryptoSwift update  version 1.4.0 [\#327](https://github.com/skywinder/web3swift/pull/327) ([lzttxs](https://github.com/lzttxs))
- Update carthage libraries [\#325](https://github.com/skywinder/web3swift/pull/325) ([alex78pro](https://github.com/alex78pro))
- Gas estimate fix [\#324](https://github.com/skywinder/web3swift/pull/324) ([frostiq](https://github.com/frostiq))
- Update README.md [\#306](https://github.com/skywinder/web3swift/pull/306) ([manuG420](https://github.com/manuG420))
- fix mnemonicsToEntropy mnemonic length check [\#301](https://github.com/skywinder/web3swift/pull/301) ([sche](https://github.com/sche))
- Updated Contract transaction method with Your ABI string [\#299](https://github.com/skywinder/web3swift/pull/299) ([veerChauhan](https://github.com/veerChauhan))
- fix crash abi parsing [\#296](https://github.com/skywinder/web3swift/pull/296) ([nerzh](https://github.com/nerzh))
- Examples, Fixed Crashes, Refactoring [\#286](https://github.com/skywinder/web3swift/pull/286) ([skywinder](https://github.com/skywinder))
- Master [\#281](https://github.com/skywinder/web3swift/pull/281) ([skywinder](https://github.com/skywinder))
- Fix Serialisation of BIP32 Keystore [\#278](https://github.com/skywinder/web3swift/pull/278) ([podkovyrin](https://github.com/podkovyrin))

## [2.3.0](https://github.com/skywinder/web3swift/tree/2.3.0) (2020-09-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.2.2...2.3.0)

**Implemented enhancements:**

- Credentials: send "Authorization" header [\#267](https://github.com/skywinder/web3swift/issues/267)

**Fixed bugs:**

- How to add web3swift in my framework ? [\#167](https://github.com/skywinder/web3swift/issues/167)
- Documentation link 404 in README.md [\#164](https://github.com/skywinder/web3swift/issues/164)

**Closed issues:**

- web3swift.Web3Error.processingError\("Failed to fetch nonce"\) [\#272](https://github.com/skywinder/web3swift/issues/272)
- Xcode 10.3 archive failed [\#266](https://github.com/skywinder/web3swift/issues/266)
- WebView: Dapp & Connect Wallet [\#264](https://github.com/skywinder/web3swift/issues/264)
- Create new contract method. [\#261](https://github.com/skywinder/web3swift/issues/261)
- Xcode 11 regenerating password [\#228](https://github.com/skywinder/web3swift/issues/228)
- support Xocde 11 SPM for iOS [\#221](https://github.com/skywinder/web3swift/issues/221)
- Not able to Deploy smart contract [\#214](https://github.com/skywinder/web3swift/issues/214)
- unable to create archive file for testflight [\#161](https://github.com/skywinder/web3swift/issues/161)

**Merged pull requests:**

- Added web3-react-native to libraries that use web3swift [\#263](https://github.com/skywinder/web3swift/pull/263) ([cawfree](https://github.com/cawfree))

## [2.2.2](https://github.com/skywinder/web3swift/tree/2.2.2) (2020-04-04)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.2.1...2.2.2)

**Implemented enhancements:**

- ENS Registry migration [\#237](https://github.com/skywinder/web3swift/issues/237)
- WKWebView with injected "web3 [\#202](https://github.com/skywinder/web3swift/issues/202)

**Fixed bugs:**

- Fix build dependencies [\#244](https://github.com/skywinder/web3swift/issues/244)
- Carthage build fails [\#226](https://github.com/skywinder/web3swift/issues/226)

**Closed issues:**

- Event filters by Param not working [\#248](https://github.com/skywinder/web3swift/issues/248)
- KeysService\(\)  in Migration guide not found [\#240](https://github.com/skywinder/web3swift/issues/240)
- How to get seed phrase from private key? [\#236](https://github.com/skywinder/web3swift/issues/236)
- Sender Value nil [\#219](https://github.com/skywinder/web3swift/issues/219)

**Merged pull requests:**

- value as optional parameter [\#256](https://github.com/skywinder/web3swift/pull/256) ([skywinder](https://github.com/skywinder))
- 2.2.2 [\#253](https://github.com/skywinder/web3swift/pull/253) ([BaldyAsh](https://github.com/BaldyAsh))
- \#248 [\#250](https://github.com/skywinder/web3swift/pull/250) ([hakumai-iida](https://github.com/hakumai-iida))
- Baldyash/webview [\#249](https://github.com/skywinder/web3swift/pull/249) ([BaldyAsh](https://github.com/BaldyAsh))
- policy [\#247](https://github.com/skywinder/web3swift/pull/247) ([BaldyAsh](https://github.com/BaldyAsh))
- Fix dependencies, build [\#245](https://github.com/skywinder/web3swift/pull/245) ([BaldyAsh](https://github.com/BaldyAsh))
- chore: update ENS Registry migration  [\#243](https://github.com/skywinder/web3swift/pull/243) ([aranhaagency](https://github.com/aranhaagency))
- important notice update [\#232](https://github.com/skywinder/web3swift/pull/232) ([skywinder](https://github.com/skywinder))
- Add Alice Wallet to project list [\#230](https://github.com/skywinder/web3swift/pull/230) ([lmcmz](https://github.com/lmcmz))
- Update Extensions.swift [\#225](https://github.com/skywinder/web3swift/pull/225) ([kocherovets](https://github.com/kocherovets))
- correct gasLimit [\#222](https://github.com/skywinder/web3swift/pull/222) ([luqz](https://github.com/luqz))
- Change BIP39 word list extension from array of strings to one string … [\#217](https://github.com/skywinder/web3swift/pull/217) ([husamettinor](https://github.com/husamettinor))
- Expose BIP39 words and separator [\#212](https://github.com/skywinder/web3swift/pull/212) ([dawiddr](https://github.com/dawiddr))

## [2.2.1](https://github.com/skywinder/web3swift/tree/2.2.1) (2019-06-24)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.2.0...2.2.1)

**Implemented enhancements:**

- 2.2.0 [\#155](https://github.com/skywinder/web3swift/issues/155)

**Closed issues:**

- BigInt 3.1 [\#207](https://github.com/skywinder/web3swift/issues/207)
- received transaction id from geth node server but not able to see that transaction id at etherscan.io [\#200](https://github.com/skywinder/web3swift/issues/200)
- How do I fetch information such as balance, decimal,symbol and name of ERC20token ?   [\#199](https://github.com/skywinder/web3swift/issues/199)
- Starscream 3.1.0 not compatible with Swift 5.0 [\#195](https://github.com/skywinder/web3swift/issues/195)
- How to Connect infuraWebsocket and subscribe particular event in swift? [\#193](https://github.com/skywinder/web3swift/issues/193)
- Use of unresolved identifier 'Wallet' [\#192](https://github.com/skywinder/web3swift/issues/192)
- V in Signed Message Hash not being calculated properly [\#191](https://github.com/skywinder/web3swift/issues/191)
- Not possible to calculate fast, normal and cheap transaction fee ? [\#190](https://github.com/skywinder/web3swift/issues/190)
- SocketProvider does not receive messages [\#188](https://github.com/skywinder/web3swift/issues/188)
- Cannot build example in v2.1.6 [\#177](https://github.com/skywinder/web3swift/issues/177)
- EIP67Code missing in web3swift 2.1.6 [\#176](https://github.com/skywinder/web3swift/issues/176)
- 'internal' protection level on Web3Error description property [\#172](https://github.com/skywinder/web3swift/issues/172)
- ENS initializer is inaccessible due to `internal` protection level [\#171](https://github.com/skywinder/web3swift/issues/171)
- Archive on Xcode 10.2 [\#166](https://github.com/skywinder/web3swift/issues/166)
- carthage not support on Xcode 10.2 [\#138](https://github.com/skywinder/web3swift/issues/138)

**Merged pull requests:**

- 2.2.1 [\#210](https://github.com/skywinder/web3swift/pull/210) ([BaldyAsh](https://github.com/BaldyAsh))
- infura v3 complete update [\#209](https://github.com/skywinder/web3swift/pull/209) ([BaldyAsh](https://github.com/BaldyAsh))
- merge Master -\> develop [\#205](https://github.com/skywinder/web3swift/pull/205) ([skywinder](https://github.com/skywinder))
- update documentation, prettify doc style [\#204](https://github.com/skywinder/web3swift/pull/204) ([skywinder](https://github.com/skywinder))
- V handle fix [\#201](https://github.com/skywinder/web3swift/pull/201) ([BaldyAsh](https://github.com/BaldyAsh))
- Update ENSBaseRegistrar.swift [\#198](https://github.com/skywinder/web3swift/pull/198) ([barrasso](https://github.com/barrasso))
- Websockets improvements and fixes [\#189](https://github.com/skywinder/web3swift/pull/189) ([BaldyAsh](https://github.com/BaldyAsh))
- Update ETHRegistrarController.swift [\#187](https://github.com/skywinder/web3swift/pull/187) ([barrasso](https://github.com/barrasso))
- Update ETHRegistrarController.swift [\#183](https://github.com/skywinder/web3swift/pull/183) ([barrasso](https://github.com/barrasso))
- Fix typo in Usage [\#182](https://github.com/skywinder/web3swift/pull/182) ([sweepty](https://github.com/sweepty))
- Expose errorDescription. [\#181](https://github.com/skywinder/web3swift/pull/181) ([andresousa](https://github.com/andresousa))
- Update ENS Resolver [\#180](https://github.com/skywinder/web3swift/pull/180) ([barrasso](https://github.com/barrasso))

## [2.2.0](https://github.com/skywinder/web3swift/tree/2.2.0) (2019-04-30)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.6...2.2.0)

**Closed issues:**

- Failed to fetch gas estimate [\#178](https://github.com/skywinder/web3swift/issues/178)

**Merged pull requests:**

- 2.2.0 [\#179](https://github.com/skywinder/web3swift/pull/179) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.6](https://github.com/skywinder/web3swift/tree/2.1.6) (2019-04-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.5...2.1.6)

**Merged pull requests:**

- 2.1.6 [\#175](https://github.com/skywinder/web3swift/pull/175) ([BaldyAsh](https://github.com/BaldyAsh))
- Quickfix ens [\#174](https://github.com/skywinder/web3swift/pull/174) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.5](https://github.com/skywinder/web3swift/tree/2.1.5) (2019-04-24)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.4...2.1.5)

**Merged pull requests:**

- Documentation update [\#153](https://github.com/skywinder/web3swift/pull/153) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.4](https://github.com/skywinder/web3swift/tree/2.1.4) (2019-04-24)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.3...2.1.4)

**Fixed bugs:**

- Cannot load module 'Web3swift' as 'web3swift [\#133](https://github.com/skywinder/web3swift/issues/133)

**Closed issues:**

- How to convert 21000 BigUInt estimated gas price into Wei ? [\#163](https://github.com/skywinder/web3swift/issues/163)
- ENS Permanent Registrar Support [\#159](https://github.com/skywinder/web3swift/issues/159)
- web3swift 2.1.3 [\#154](https://github.com/skywinder/web3swift/issues/154)
- Sending ETH always results in zero value [\#149](https://github.com/skywinder/web3swift/issues/149)
- WebSockets subscriptions [\#145](https://github.com/skywinder/web3swift/issues/145)
- 依赖该库生成framework，真机情况下会出现问题 [\#143](https://github.com/skywinder/web3swift/issues/143)
- Building fails with compilation errors [\#140](https://github.com/skywinder/web3swift/issues/140)

**Merged pull requests:**

- Fix travis [\#169](https://github.com/skywinder/web3swift/pull/169) ([BaldyAsh](https://github.com/BaldyAsh))
- Fix warnings [\#168](https://github.com/skywinder/web3swift/pull/168) ([BaldyAsh](https://github.com/BaldyAsh))
- Added reverse registrar [\#165](https://github.com/skywinder/web3swift/pull/165) ([BaldyAsh](https://github.com/BaldyAsh))
- WIP: ENS BaseRegistrar and RegistrarController support [\#162](https://github.com/skywinder/web3swift/pull/162) ([BaldyAsh](https://github.com/BaldyAsh))
- Updated example to 2.1.3 [\#158](https://github.com/skywinder/web3swift/pull/158) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.3](https://github.com/skywinder/web3swift/tree/2.1.3) (2019-04-06)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.2...2.1.3)

**Implemented enhancements:**

- WIP: WebSockets subscriptions [\#144](https://github.com/skywinder/web3swift/pull/144) ([BaldyAsh](https://github.com/BaldyAsh))

**Closed issues:**

- Use custom JSONRPCmethod and Units [\#148](https://github.com/skywinder/web3swift/issues/148)
- ERC20 some functions are not working  [\#146](https://github.com/skywinder/web3swift/issues/146)
- fix `pod install` absolute paths [\#97](https://github.com/skywinder/web3swift/issues/97)
- Installing issue by pod [\#76](https://github.com/skywinder/web3swift/issues/76)

**Merged pull requests:**

- 2.1.3 fix No2 [\#152](https://github.com/skywinder/web3swift/pull/152) ([BaldyAsh](https://github.com/BaldyAsh))
- 2.1.3 fix [\#151](https://github.com/skywinder/web3swift/pull/151) ([BaldyAsh](https://github.com/BaldyAsh))
- 2.1.3 [\#150](https://github.com/skywinder/web3swift/pull/150) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.2](https://github.com/skywinder/web3swift/tree/2.1.2) (2019-03-30)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.1...2.1.2)

**Merged pull requests:**

- Swift 5 update [\#141](https://github.com/skywinder/web3swift/pull/141) ([BaldyAsh](https://github.com/BaldyAsh))
- Swift 5 update [\#139](https://github.com/skywinder/web3swift/pull/139) ([BaldyAsh](https://github.com/BaldyAsh))
- 2.1.1 [\#136](https://github.com/skywinder/web3swift/pull/136) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.1](https://github.com/skywinder/web3swift/tree/2.1.1) (2019-03-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.1.0...2.1.1)

**Implemented enhancements:**

- Support ST-20 [\#103](https://github.com/skywinder/web3swift/issues/103)

**Closed issues:**

- Expected to decode Array\<Any\> but found a dictionary instead. [\#128](https://github.com/skywinder/web3swift/issues/128)
- Decoding Input/Output data [\#127](https://github.com/skywinder/web3swift/issues/127)
- nodeError\("replacement transaction underpriced"\) [\#42](https://github.com/skywinder/web3swift/issues/42)

**Merged pull requests:**

- Fix/podspec [\#135](https://github.com/skywinder/web3swift/pull/135) ([BaldyAsh](https://github.com/BaldyAsh))
- let some functions public for customization [\#132](https://github.com/skywinder/web3swift/pull/132) ([scottphc](https://github.com/scottphc))
- WIP: ST-20 and Security Token support [\#130](https://github.com/skywinder/web3swift/pull/130) ([BaldyAsh](https://github.com/BaldyAsh))
- Fix/remove deprecated [\#120](https://github.com/skywinder/web3swift/pull/120) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.1.0](https://github.com/skywinder/web3swift/tree/2.1.0) (2019-03-06)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.0.4...2.1.0)

**Implemented enhancements:**

- Support ERC-888 [\#102](https://github.com/skywinder/web3swift/issues/102)
- Support SRC-20 [\#101](https://github.com/skywinder/web3swift/issues/101)
- Support S3 [\#99](https://github.com/skywinder/web3swift/issues/99)
- Support ERC-1400 [\#98](https://github.com/skywinder/web3swift/issues/98)
- ERC-165 support [\#82](https://github.com/skywinder/web3swift/issues/82)
- ERC-777 support [\#81](https://github.com/skywinder/web3swift/issues/81)
- How do I add an account to a node [\#78](https://github.com/skywinder/web3swift/issues/78)
- ERC20 API Support [\#41](https://github.com/skywinder/web3swift/issues/41)
- Support Web3View functionality [\#30](https://github.com/skywinder/web3swift/issues/30)

**Closed issues:**

- eth\_estimateGas is not supplied the gasPrice parameter [\#118](https://github.com/skywinder/web3swift/issues/118)
- Carthage support missing. [\#115](https://github.com/skywinder/web3swift/issues/115)
- \[Utility\] Contract event listener [\#112](https://github.com/skywinder/web3swift/issues/112)
- Support ERC-1644 [\#111](https://github.com/skywinder/web3swift/issues/111)
- Support ERC-1643 [\#110](https://github.com/skywinder/web3swift/issues/110)
- Support ERC-1594 [\#109](https://github.com/skywinder/web3swift/issues/109)
- Support ERC-1410 [\#108](https://github.com/skywinder/web3swift/issues/108)
- Support ERC-820 [\#107](https://github.com/skywinder/web3swift/issues/107)
- Error: Failed to fetch gas estimate on intermediate call [\#106](https://github.com/skywinder/web3swift/issues/106)
- Can't use ENS in 2.0 [\#92](https://github.com/skywinder/web3swift/issues/92)
- Can't use EIP681 parser [\#91](https://github.com/skywinder/web3swift/issues/91)
- enhancement - end to end newbie instructions to deploy erc20 token locally / initialize wallets - then successfully transfer it in app [\#89](https://github.com/skywinder/web3swift/issues/89)
- Can you support objective-c [\#88](https://github.com/skywinder/web3swift/issues/88)
- SolidityType has no member 'allSatisfy'？ [\#87](https://github.com/skywinder/web3swift/issues/87)
- How to encode data for appending constructor to bytecode for deploying contract? [\#86](https://github.com/skywinder/web3swift/issues/86)
- web3swift.Web3Error error 4 for get balance [\#77](https://github.com/skywinder/web3swift/issues/77)
- How to signed Transaction ? get raw [\#62](https://github.com/skywinder/web3swift/issues/62)
- how to get token using Signing Transaction [\#58](https://github.com/skywinder/web3swift/issues/58)
- Can the signtypedMessage function be added [\#45](https://github.com/skywinder/web3swift/issues/45)
- Migration to web3 format \(create account\) [\#40](https://github.com/skywinder/web3swift/issues/40)
- How to get Keystore by PrivateKeyData ? [\#19](https://github.com/skywinder/web3swift/issues/19)
- encoding name\(ens\) for sending register contract [\#15](https://github.com/skywinder/web3swift/issues/15)

**Merged pull requests:**

- 2.1.0 [\#124](https://github.com/skywinder/web3swift/pull/124) ([BaldyAsh](https://github.com/BaldyAsh))
- Fix/remove deprecated [\#123](https://github.com/skywinder/web3swift/pull/123) ([BaldyAsh](https://github.com/BaldyAsh))
- fixed estimate gas problem [\#119](https://github.com/skywinder/web3swift/pull/119) ([BaldyAsh](https://github.com/BaldyAsh))
- Added Deed and Registrar ABI to Web3+Utils [\#114](https://github.com/skywinder/web3swift/pull/114) ([barrasso](https://github.com/barrasso))
- Fixed EIP681 and EIP67, added and improved a lot of ERCs [\#113](https://github.com/skywinder/web3swift/pull/113) ([BaldyAsh](https://github.com/BaldyAsh))
- Documentation [\#105](https://github.com/skywinder/web3swift/pull/105) ([BaldyAsh](https://github.com/BaldyAsh))
- recent changes [\#104](https://github.com/skywinder/web3swift/pull/104) ([BaldyAsh](https://github.com/BaldyAsh))
- Migration to 2.0 [\#96](https://github.com/skywinder/web3swift/pull/96) ([BaldyAsh](https://github.com/BaldyAsh))
- Master to develop for 2.0.2 [\#94](https://github.com/skywinder/web3swift/pull/94) ([shamatar](https://github.com/shamatar))
- 2.0.2 [\#93](https://github.com/skywinder/web3swift/pull/93) ([shamatar](https://github.com/shamatar))
- Feature/readme improvement [\#85](https://github.com/skywinder/web3swift/pull/85) ([BaldyAsh](https://github.com/BaldyAsh))
- Get recent develop changes [\#80](https://github.com/skywinder/web3swift/pull/80) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.0.4](https://github.com/skywinder/web3swift/tree/2.0.4) (2018-11-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.0.3...2.0.4)

## [2.0.3](https://github.com/skywinder/web3swift/tree/2.0.3) (2018-11-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.0.2...2.0.3)

## [2.0.2](https://github.com/skywinder/web3swift/tree/2.0.2) (2018-11-06)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.0.1...2.0.2)

**Merged pull requests:**

- 2.0.1 [\#84](https://github.com/skywinder/web3swift/pull/84) ([shamatar](https://github.com/shamatar))

## [2.0.1](https://github.com/skywinder/web3swift/tree/2.0.1) (2018-11-05)

[Full Changelog](https://github.com/skywinder/web3swift/compare/2.0.0...2.0.1)

**Closed issues:**

- ENS Functionality [\#56](https://github.com/skywinder/web3swift/issues/56)

**Merged pull requests:**

- ENS fix [\#83](https://github.com/skywinder/web3swift/pull/83) ([BaldyAsh](https://github.com/BaldyAsh))

## [2.0.0](https://github.com/skywinder/web3swift/tree/2.0.0) (2018-10-30)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.5.1...2.0.0)

**Implemented enhancements:**

- Carthage support [\#44](https://github.com/skywinder/web3swift/issues/44)
- How to get pending transactions by this framework [\#36](https://github.com/skywinder/web3swift/issues/36)
- ENS for wallets [\#12](https://github.com/skywinder/web3swift/issues/12)
- Recover passphrase from BIP32 store [\#5](https://github.com/skywinder/web3swift/issues/5)
- ERC20 API Support [\#41](https://github.com/skywinder/web3swift/issues/41)

**Closed issues:**

- failed to send transaction due to known transaction [\#65](https://github.com/skywinder/web3swift/issues/65)
- List of all transactions related to account \(private key\) [\#57](https://github.com/skywinder/web3swift/issues/57)
- Make A README & doc [\#46](https://github.com/skywinder/web3swift/issues/46)
- 'BigUInt' is ambiguous for type lookup in this conte [\#43](https://github.com/skywinder/web3swift/issues/43)
- Migration to web3 format \(create account\) [\#40](https://github.com/skywinder/web3swift/issues/40)
- Interface ideas are welcome for v2.0 [\#3](https://github.com/skywinder/web3swift/issues/3)

**Merged pull requests:**

- Carthage [\#75](https://github.com/skywinder/web3swift/pull/75) ([BaldyAsh](https://github.com/BaldyAsh))
- Carthage fixes [\#74](https://github.com/skywinder/web3swift/pull/74) ([BaldyAsh](https://github.com/BaldyAsh))

## [1.5.1](https://github.com/skywinder/web3swift/tree/1.5.1) (2018-10-22)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.5...1.5.1)

**Merged pull requests:**

- Function visibility fix [\#70](https://github.com/skywinder/web3swift/pull/70) ([shamatar](https://github.com/shamatar))

## [1.5](https://github.com/skywinder/web3swift/tree/1.5) (2018-10-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.10...1.5)

**Implemented enhancements:**

- Can you add support for ERC-721 tokens [\#7](https://github.com/skywinder/web3swift/issues/7)

**Closed issues:**

- Creating a new wallet is too slow [\#63](https://github.com/skywinder/web3swift/issues/63)
- need to update for Xcode10 [\#49](https://github.com/skywinder/web3swift/issues/49)
- Web3.Utils.formatToEthereumUnits  [\#48](https://github.com/skywinder/web3swift/issues/48)
- Interface ideas are welcome for v2.0 [\#3](https://github.com/skywinder/web3swift/issues/3)

**Merged pull requests:**

- Add TxPool and ERC721 native class [\#68](https://github.com/skywinder/web3swift/pull/68) ([shamatar](https://github.com/shamatar))
- Feature/erc721 [\#67](https://github.com/skywinder/web3swift/pull/67) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/adding logo [\#66](https://github.com/skywinder/web3swift/pull/66) ([BaldyAsh](https://github.com/BaldyAsh))
- adds txpool function and its local node test [\#64](https://github.com/skywinder/web3swift/pull/64) ([currybab](https://github.com/currybab))
- License got reverted somewhere after PRs [\#60](https://github.com/skywinder/web3swift/pull/60) ([shamatar](https://github.com/shamatar))

## [1.1.10](https://github.com/skywinder/web3swift/tree/1.1.10) (2018-10-04)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.9...1.1.10)

**Merged pull requests:**

- Preliminary ENS support, start module splitting [\#59](https://github.com/skywinder/web3swift/pull/59) ([shamatar](https://github.com/shamatar))
- Feature/readme improvement [\#55](https://github.com/skywinder/web3swift/pull/55) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/support obj c [\#54](https://github.com/skywinder/web3swift/pull/54) ([BaldyAsh](https://github.com/BaldyAsh))
- Feature/ENSsupport [\#53](https://github.com/skywinder/web3swift/pull/53) ([FesenkoG](https://github.com/FesenkoG))
- Add Travis configuration [\#52](https://github.com/skywinder/web3swift/pull/52) ([skywinder](https://github.com/skywinder))
- Added ERC-20 token for testing web3swift lib [\#50](https://github.com/skywinder/web3swift/pull/50) ([BaldyAsh](https://github.com/BaldyAsh))

## [1.1.9](https://github.com/skywinder/web3swift/tree/1.1.9) (2018-09-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.7...1.1.9)

**Fixed bugs:**

- eth.getAccounts\(\) function returns an empty address Array [\#24](https://github.com/skywinder/web3swift/issues/24)
- EIP681 bug fixes, accessibility in Function changed [\#35](https://github.com/skywinder/web3swift/pull/35) ([FesenkoG](https://github.com/FesenkoG))

**Closed issues:**

- the version 1.1.6 couldn't from password and keystore to  get the privateKey [\#32](https://github.com/skywinder/web3swift/issues/32)
- Need implementation of EIP-681 parsing  [\#25](https://github.com/skywinder/web3swift/issues/25)

**Merged pull requests:**

- Update for XCode 10 [\#39](https://github.com/skywinder/web3swift/pull/39) ([shamatar](https://github.com/shamatar))
- Basic ENS support added, EIP681 parsing supports ENS from now. [\#38](https://github.com/skywinder/web3swift/pull/38) ([FesenkoG](https://github.com/FesenkoG))

## [1.1.7](https://github.com/skywinder/web3swift/tree/1.1.7) (2018-09-13)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.6...1.1.7)

**Fixed bugs:**

- Thread blocked [\#16](https://github.com/skywinder/web3swift/issues/16)

**Closed issues:**

- How to create same address and keystore by mnemonics? [\#22](https://github.com/skywinder/web3swift/issues/22)

**Merged pull requests:**

- Fix ethereum address parsing, add readme [\#34](https://github.com/skywinder/web3swift/pull/34) ([shamatar](https://github.com/shamatar))
- complete EIP681, fix the most stupid Ethereum address parsing [\#33](https://github.com/skywinder/web3swift/pull/33) ([shamatar](https://github.com/shamatar))
- Add examples to readme, prettify formatting [\#31](https://github.com/skywinder/web3swift/pull/31) ([skywinder](https://github.com/skywinder))
- continue eip681 work [\#27](https://github.com/skywinder/web3swift/pull/27) ([shamatar](https://github.com/shamatar))
- Implement EIP681 parser \(untested\) [\#26](https://github.com/skywinder/web3swift/pull/26) ([shamatar](https://github.com/shamatar))
- Change access control of function fromRaw in struct EthereumTransaction [\#11](https://github.com/skywinder/web3swift/pull/11) ([Plazmathron](https://github.com/Plazmathron))

## [1.1.6](https://github.com/skywinder/web3swift/tree/1.1.6) (2018-09-04)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.5...1.1.6)

**Merged pull requests:**

- Quick fix for scrypt performance [\#17](https://github.com/skywinder/web3swift/pull/17) ([shamatar](https://github.com/shamatar))
- adding description string to Web3Error [\#1](https://github.com/skywinder/web3swift/pull/1) ([GabCas](https://github.com/GabCas))

## [1.1.5](https://github.com/skywinder/web3swift/tree/1.1.5) (2018-08-10)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.1...1.1.5)

## [1.1.1](https://github.com/skywinder/web3swift/tree/1.1.1) (2018-07-30)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.1.0...1.1.1)

## [1.1.0](https://github.com/skywinder/web3swift/tree/1.1.0) (2018-07-27)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.0.1...1.1.0)

## [1.0.1](https://github.com/skywinder/web3swift/tree/1.0.1) (2018-07-12)

[Full Changelog](https://github.com/skywinder/web3swift/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/skywinder/web3swift/tree/1.0.0) (2018-07-04)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.9.0...1.0.0)

## [0.9.0](https://github.com/skywinder/web3swift/tree/0.9.0) (2018-06-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.8.1...0.9.0)

## [0.8.1](https://github.com/skywinder/web3swift/tree/0.8.1) (2018-06-10)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.8.0...0.8.1)

## [0.8.0](https://github.com/skywinder/web3swift/tree/0.8.0) (2018-05-31)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.7.9...0.8.0)

## [0.7.9](https://github.com/skywinder/web3swift/tree/0.7.9) (2018-05-31)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.7.0...0.7.9)

## [0.7.0](https://github.com/skywinder/web3swift/tree/0.7.0) (2018-05-11)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.6.0...0.7.0)

## [0.6.0](https://github.com/skywinder/web3swift/tree/0.6.0) (2018-04-24)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.6...0.6.0)

## [0.5.6](https://github.com/skywinder/web3swift/tree/0.5.6) (2018-04-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.5...0.5.6)

## [0.5.5](https://github.com/skywinder/web3swift/tree/0.5.5) (2018-04-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.4...0.5.5)

## [0.5.4](https://github.com/skywinder/web3swift/tree/0.5.4) (2018-04-16)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.3...0.5.4)

## [0.5.3](https://github.com/skywinder/web3swift/tree/0.5.3) (2018-04-16)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.2...0.5.3)

## [0.5.2](https://github.com/skywinder/web3swift/tree/0.5.2) (2018-04-16)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.1...0.5.2)

## [0.5.1](https://github.com/skywinder/web3swift/tree/0.5.1) (2018-04-11)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.5.0...0.5.1)

## [0.5.0](https://github.com/skywinder/web3swift/tree/0.5.0) (2018-04-10)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.4.1...0.5.0)

## [0.4.1](https://github.com/skywinder/web3swift/tree/0.4.1) (2018-04-07)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.4.0...0.4.1)

## [0.4.0](https://github.com/skywinder/web3swift/tree/0.4.0) (2018-04-04)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.6...0.4.0)

## [0.3.6](https://github.com/skywinder/web3swift/tree/0.3.6) (2018-04-02)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.5...0.3.6)

## [0.3.5](https://github.com/skywinder/web3swift/tree/0.3.5) (2018-03-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.4...0.3.5)

## [0.3.4](https://github.com/skywinder/web3swift/tree/0.3.4) (2018-03-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.3...0.3.4)

## [0.3.3](https://github.com/skywinder/web3swift/tree/0.3.3) (2018-03-05)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.2...0.3.3)

## [0.3.2](https://github.com/skywinder/web3swift/tree/0.3.2) (2018-03-03)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.1...0.3.2)

## [0.3.1](https://github.com/skywinder/web3swift/tree/0.3.1) (2018-03-01)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/skywinder/web3swift/tree/0.3.0) (2018-02-27)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.99...0.3.0)

## [0.2.99](https://github.com/skywinder/web3swift/tree/0.2.99) (2018-02-27)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.98...0.2.99)

## [0.2.98](https://github.com/skywinder/web3swift/tree/0.2.98) (2018-02-27)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.12...0.2.98)

## [0.2.12](https://github.com/skywinder/web3swift/tree/0.2.12) (2018-02-01)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.11...0.2.12)

## [0.2.11](https://github.com/skywinder/web3swift/tree/0.2.11) (2018-02-01)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.10...0.2.11)

## [0.2.10](https://github.com/skywinder/web3swift/tree/0.2.10) (2018-01-31)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.9...0.2.10)

## [0.2.9](https://github.com/skywinder/web3swift/tree/0.2.9) (2018-01-29)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.8...0.2.9)

## [0.2.8](https://github.com/skywinder/web3swift/tree/0.2.8) (2018-01-18)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.7...0.2.8)

## [0.2.7](https://github.com/skywinder/web3swift/tree/0.2.7) (2018-01-15)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.5...0.2.7)

## [0.2.5](https://github.com/skywinder/web3swift/tree/0.2.5) (2018-01-12)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.2.0...0.2.5)

## [0.2.0](https://github.com/skywinder/web3swift/tree/0.2.0) (2017-12-30)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.1.2...0.2.0)

## [0.1.2](https://github.com/skywinder/web3swift/tree/0.1.2) (2017-12-27)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/skywinder/web3swift/tree/0.1.1) (2017-12-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/skywinder/web3swift/tree/0.1.0) (2017-12-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.6...0.1.0)

## [0.0.6](https://github.com/skywinder/web3swift/tree/0.0.6) (2017-12-26)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.5...0.0.6)

## [0.0.5](https://github.com/skywinder/web3swift/tree/0.0.5) (2017-12-21)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.4...0.0.5)

## [0.0.4](https://github.com/skywinder/web3swift/tree/0.0.4) (2017-12-21)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.3...0.0.4)

## [0.0.3](https://github.com/skywinder/web3swift/tree/0.0.3) (2017-12-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/skywinder/web3swift/tree/0.0.2) (2017-12-20)

[Full Changelog](https://github.com/skywinder/web3swift/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/skywinder/web3swift/tree/0.0.1) (2017-12-19)

[Full Changelog](https://github.com/skywinder/web3swift/compare/3b32224461f8510e743fa23bccbb437269f98525...0.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
