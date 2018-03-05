Pod::Spec.new do |s|
s.name             = "web3swift"
s.version          = "0.3.3"
s.summary          = "Web3 implementation in vanilla Swift for iOS ans macOS"

s.description      = <<-DESC
Web3 implementation in vanilla Swift, intended for mobile developers of wallets, Dapps and Web3.0
DESC

s.homepage         = "https://github.com/bankex/web3swift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "av@bankexfoundation.org" }
s.source           = { :git => 'https://github.com/bankex/web3swift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'

s.pod_target_xcconfig = {
  'SWIFT_VERSION' => '4.0',
	'ARCHS' => '${ARCHS_STANDARD_64_BIT}', 
	'VALID_ARCHS' => '${ARCHS_STANDARD_64_BIT}'
}

s.module_name = 'web3swift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.13"
s.source_files = "web3swift/**/*.{h,swift}", 
s.public_header_files = "web3swift/**/*.{h}"


s.dependency 'Alamofire', '~> 4.6'
s.dependency 'Alamofire-Synchronous', '~> 4.0'
s.dependency 'BigInt', '~> 3.0.1'
s.dependency 'Result', '~> 3.0.0'
s.dependency 'CryptoSwift', '~> 0.8.3'
s.dependency 'libsodium', '~> 1.0.12'
s.dependency 'secp256k1_ios', '~> 0.1.2'

end
