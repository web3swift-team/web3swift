
Pod::Spec.new do |spec|
    spec.name         = 'BigInt'
    spec.version      = '3.1.0'
    spec.ios.deployment_target = "8.0"
    spec.osx.deployment_target = "10.9"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    spec.summary      = 'Arbitrary-precision arithmetic in pure Swift'
    spec.homepage     = 'https://github.com/attaswift/BigInt'
    spec.author       = 'Károly Lőrentey'
    spec.source       = { :git => 'https://github.com/attaswift/BigInt.git', :tag => 'v' + String(spec.version) }
    spec.source_files = 'sources/*.swift'
    spec.social_media_url = 'https://twitter.com/lorentey'
    spec.documentation_url = 'http://attaswift.github.io/BigInt/'
    spec.dependency 'SipHash', '~> 1.2'
end
