def import_pods
  pod 'Starscream', '3.1.0'
  pod 'PromiseKit', '6.8.4'
  pod 'BigInt', '3.1'
  pod 'CryptoSwift', '1.0.0'
  pod 'secp256k1_swift', '1.0.3', :modular_headers => true
end

target 'web3swift-macOS' do
  platform :osx, '10.11'
#  use_frameworks!
  use_modular_headers!
  import_pods
  
  target 'web3swift-macOS_Tests' do
    inherit! :search_paths
  end
end

target 'web3swift-iOS' do
  platform :ios, '9.0'
#  use_frameworks!
  use_modular_headers! 
  import_pods
  
  target 'web3swift-iOS_Tests' do
    inherit! :search_paths
  end
end
