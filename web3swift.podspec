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
    spec.source_files = "Sources/EthereumABI/*.swift", "Sources/EthereumAddress/*.swift", "Sources/SwiftRLP/*.swift",  "Sources/web3swift/{Transaction,Contract,Web3,Promises,HookedFunctions,KeystoreManager,Convenience}/*.swift", "Sources/web3swift/Utils/**/*.swift", "Sources/web3swift/PrecompiledContracts/**/*.swift", "Sources/secp256k1/*.{h,c}", "Sources/secp256k1/include/*.{h,c}"
    spec.swift_version = '5.0'
    spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    spec.module_name = 'Web3swift'
    spec.frameworks = 'CoreImage'
    spec.dependency 'PromiseKit', '6.8.4'
    spec.dependency 'BigInt', '3.1'
    spec.dependency 'CryptoSwift', '1,0,0'
    spec.dependency 'Starscream', '3.1.0'
    
end
