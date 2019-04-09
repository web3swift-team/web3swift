Pod::Spec.new do |spec|
    spec.name         = 'SipHash'
    spec.version      = '1.2.0'
    spec.ios.deployment_target = "8.0"
    spec.osx.deployment_target = "10.9"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.summary      = 'Simple and secure hashing in Swift with the SipHash algorithm'
    spec.author       = 'Károly Lőrentey'
    spec.homepage     = 'https://github.com/attaswift/SipHash'
    spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    spec.source       = { :git => 'https://github.com/attaswift/SipHash.git', :tag => 'v' + String(spec.version) }
    spec.source_files = 'SipHash/*.swift'
    spec.social_media_url = 'https://twitter.com/lorentey'
    spec.documentation_url = 'http://attaswift.github.io/SipHash/'
end
