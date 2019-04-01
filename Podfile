def import_pods
  pod 'Starscream', '~> 3.0.2'
  pod 'PromiseKit', '~> 6.8.3'
  pod 'BigInt', '~> 3.1.0'
  pod 'CryptoSwift', '~> 0.15.0'
  pod 'secp256k1_swift', '~> 1.0.3', :modular_headers => true
  pod 'SwiftRLP', '~> 1.2'
  pod 'EthereumAddress', '~> 1.1.0'
  pod 'EthereumABI', '~> 1.2.0'
end

target 'web3swift-macOS' do
  platform :osx, '10.12'
#  use_frameworks!
  use_modular_headers!
  import_pods
  
  target 'web3swift-macOS_Tests' do
    inherit! :search_paths
  end
end

target 'web3swift-iOS' do
  platform :ios, '10.0'
#  use_frameworks!
  use_modular_headers! 
  import_pods
  
  target 'web3swift-iOS_Tests' do
    inherit! :search_paths
  end
end
