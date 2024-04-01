WEB3CORE_VERSION ||= '3.1.1'

Pod::Spec.new do |spec|
    spec.name         = 'web3swift'
    spec.version      = WEB3CORE_VERSION
    spec.ios.deployment_target = "13.0"
    spec.osx.deployment_target = "10.15"
    spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE.md' }
    spec.summary      = 'Web3 implementation in vanilla Swift for iOS, macOS, and Linux'
    spec.homepage     = 'https://github.com/web3swift-team/web3swift'
    spec.author       = {"Alex Vlasov" => "alex.m.vlasov@gmail.com", "Anton Grigorev" => "antongrigorjev2010@gmail.com", "Petr Korolev" => "sky4winder@gmail.com", "Yaroslav Yashin" => "yaroslav.yashin@gmail.com"}
    spec.source       = { :git => 'https://github.com/web3swift-team/web3swift.git', :tag => spec.version.to_s }
    spec.swift_version = '5.5'

    # Make this line same as Web3Core sources
    spec.source_files =  "Sources/web3swift/**/*.swift"
    spec.ios.source_files   = 'Sources/web3swift/Browser/*.swift'
    spec.resource_bundle = { "Browser" => "Sources/web3swift/Browser/*.js" }
    spec.frameworks = 'CoreImage'
    spec.dependency 'Starscream', '~> 4.0.4'
    spec.dependency 'Web3Core', "~> #{WEB3CORE_VERSION}"
end
