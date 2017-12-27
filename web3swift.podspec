Pod::Spec.new do |s|
s.name             = "web3swift"
s.version          = "0.1.2"
s.summary          = "Web3 implementation in vanilla Swift"

s.description      = <<-DESC
Web3 implementation in vanilla Swift, intended for mobile developers of wallets, dapps and Web3.0
DESC

s.homepage         = "https://github.com/bankex/web3swift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "av@bankexfoundation.org" }
s.source           = { :git => 'https://github.com/bankex/web3swift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'
s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0'
}
s.module_name      = 'web3swift'
s.ios.deployment_target = "11.0"
s.source_files = "web3swift/**/*.{h,swift}", 
s.public_header_files = "web3swift/**/*.{h}"
s.dependency 'Alamofire', '~> 4.5'
s.dependency 'BigInt', '~> 3.0.1'
s.dependency 'PromiseKit', '~> 4.4'
s.dependency 'AwaitKit', '~> 3.0.1'
s.dependency 'PromiseKit/Alamofire', '~> 4.0'
s.dependency 'CryptoSwift'
s.dependency 'libsodium'
s.dependency 'secp256k1_ios', '~> 0.0.7'

end
