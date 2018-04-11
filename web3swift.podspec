Pod::Spec.new do |s|
s.name             = "web3swift"
s.version          = "0.5.1"
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
  'SWIFT_VERSION' => '4.0'
}

s.module_name = 'web3swift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.13"
s.source_files = "web3swift/**/*.{h,swift}", 
s.public_header_files = "web3swift/**/*.{h}"

s.frameworks = 'CoreImage'
s.dependency 'Alamofire', '~> 4.7'
s.dependency 'Alamofire-Synchronous', '~> 4.0'
s.dependency 'BigInt', '~> 3.0.1'
s.dependency 'Result', '~> 3.0.0'
s.dependency 'CryptoSwift', '~> 0.9.0'
s.dependency 'libsodium', '~> 1.0.12'
s.dependency 'secp256k1_ios', '~> 0.1.3'

end
