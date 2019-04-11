Pod::Spec.new do |s|
s.name             = "pocket-web3swift"
s.version          = "2.1.5"
s.summary          = "Same web3swift pod version with minor changes for Pocket"

s.description      = <<-DESC
Web3 implementation in vanilla Swift, intended for mobile developers of wallets, Dapps and Web3.0.
DESC

s.homepage         = "https://github.com/pokt-network/web3swift"
s.license          = 'Apache License 2.0'
s.author           = { "Pabel Nunez" => "pabel@pokt.network" }
s.source           = { :git => 'https://github.com/pokt-network/web3swift.git', :tag => s.version.to_s }

s.swift_version = '5.0'
s.module_name = 'Web3swift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.11"
s.source_files = "web3swift/{Promises,Web3,Contract,KeystoreManager,Transaction,Convenience,HookedFunctions}/Classes/*.{h,swift}", "web3swift/Utils/Classes/{EIP67Code, EIP681, ENS, ENSResolver, NonceMiddleware}.swift", "web3swift/PrecompiledContracts/**/*.swift", "web3swift/web3swift.h"
s.public_header_files = "web3swift/web3swift.h"
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.frameworks = 'CoreImage'
s.dependency 'BigInt', '3.1'
s.dependency 'CryptoSwift', '0.15.0'
s.dependency 'PromiseKit', '6.4.1'
s.dependency 'secp256k1_swift', '1.0.3'
s.dependency 'SwiftRLP', '1.1'
s.dependency 'EthereumAddress', '1.0.0'
s.dependency 'EthereumABI', '1.1.1'
s.dependency 'Starscream', '3.1.0'
end
