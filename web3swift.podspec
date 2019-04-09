Pod::Spec.new do |spec|
    spec.name         = 'web3swift'
    spec.version      = '2.2.0'
    spec.ios.deployment_target = "9.0"
    spec.osx.deployment_target = "10.11"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE.md' }
    spec.summary      = 'Web3 implementation in vanilla Swift for iOS, macOS, tvOS, watchOS and Linux'
    spec.description  = 'Web3 implementation in vanilla Swift, intended for developers of wallets, DApps and Web3.0'
    spec.homepage     = 'https://github.com/matter-labs/web3swift'
    spec.author       = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
    spec.social_media_url = 'https://twitter.com/shamatar'
    spec.source       = { :git => 'https://github.com/matter-labs/web3swift.git', :tag => spec.version }
    spec.source_files = "Sources/EthereumABI/Classes/*.swift", "Sources/EthereumAddress/Classes/*.swift", "Sources/SwiftRLP/Classes/*.swift",  "Sources/web3swift/{Promises,Web3,Contract,KeystoreManager,Transaction,Convenience,HookedFunctions}/Classes/*.{h,swift}", "web3swift/Utils/Classes/{EIP67Code, EIP681, ENS, ENSResolver, NameHash}.swift", "web3swift/PrecompiledContracts/**/*.swift", "web3swift/web3swift.h"
    spec.swift_version = '5.0'
    spec.module_name = 'Web3swift'
    spec.dependency 'PromiseKit', '6.8'
    spec.dependency 'BigInt', '3.1'
    spec.dependency 'CryptoSwift', '0.15.0'
    spec.dependency 'Starscream', '3.1.0'
    spec.dependency 'secp256k1.c', '0.1'
end
