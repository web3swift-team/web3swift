Pod::Spec.new do |spec|
    spec.compiler_flags = '-DCOCOAPODS'

    spec.name         = 'Web3Core'
    spec.version      = '3.1.1'
    spec.ios.deployment_target = "13.0"
    spec.osx.deployment_target = "10.15"
    spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE.md' }
    spec.summary      = 'Core of web3swift library'
    spec.homepage     = 'https://github.com/web3swift-team/web3swift'
    spec.author       = {"Alex Vlasov" => "alex.m.vlasov@gmail.com", "Anton Grigorev" => "antongrigorjev2010@gmail.com", "Petr Korolev" => "sky4winder@gmail.com", "Yaroslav Yashin" => "yaroslav.yashin@gmail.com"}
    spec.source       = { :git => 'https://github.com/web3swift-team/web3swift.git', :tag => spec.version.to_s }
    spec.swift_version = '5.5'

    spec.dependency 'secp256k1.c', '~> 0.1'
    spec.dependency 'BigInt', '~> 5.2.0' # no newer version in pods.
    spec.dependency 'CryptoSwift', '~> 1.5.1'
    spec.source_files = "Sources/Web3Core/**/*.swift"
end
