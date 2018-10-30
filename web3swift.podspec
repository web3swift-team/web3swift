Pod::Spec.new do |s|
s.name             = "web3swift"
s.version          = "2.0.0"
s.summary          = "Web3 implementation in vanilla Swift for iOS ans macOS"

s.description      = <<-DESC
Web3 implementation in vanilla Swift, intended for mobile developers of wallets, Dapps and Web3.0
DESC

s.homepage         = "https://github.com/matterinc/web3swift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
s.source           = { :git => 'https://github.com/matterinc/web3swift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'

s.swift_version = '4.1'
s.module_name = 'Web3swift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.11"
s.source_files = "web3swift/**/*.{h,swift}", 
s.exclude_files = "web3swift/ObjectiveCbridge/Classes/*.{swift}", "web3swift/Utils/Classes/ENS.swift", "web3swift/Utils/Classes/ENSResolver.swift"
s.public_header_files = "web3swift/**/*.{h}"
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.frameworks = 'CoreImage'
s.dependency 'BigInt', '~> 3.1'
s.dependency 'CryptoSwift', '~> 0.13'
s.dependency 'PromiseKit', '~> 6.3'
s.dependency 'scrypt', '~> 2.0'
s.dependency 'secp256k1_swift', '~> 1.0.3'
s.dependency 'SwiftRLP', '~> 1.1'
s.dependency 'EthereumAddress', '~> 1.0.0'
s.dependency 'EthereumABI', '~> 1.1.1'
end
