def import_pods
  pod 'Alamofire', '~> 4.5'
  pod 'Alamofire-Synchronous', '~> 4.0'
  pod 'BigInt', '~> 3.0.1'
  pod 'CryptoSwift'
  pod 'Result', '~> 3.0.0'
  pod 'libsodium'
  pod 'secp256k1_ios', :git => 'https://github.com/shamatar/secp256k1_ios.git'
end

target 'web3swift-macOS' do
  platform :osx, '10.13'
  use_frameworks!
  
  import_pods
  
  target 'web3swift-macOS_Tests' do
    inherit! :search_paths
  end
end

target 'web3swift-iOS' do
  platform :ios, '11.2'
  use_frameworks!
  
  import_pods
  
  target 'web3swift-iOS_Tests' do
    inherit! :search_paths
  end
end
