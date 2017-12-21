Pod::Spec.new do |s|
s.name             = "secp256k1_ios"
s.version          = "0.0.5"
s.summary          = "Reference sepc256k1 implementation as pod"

s.description      = <<-DESC
secp256k1 libraty portable pod
DESC

s.homepage         = "https://github.com/shamatar/secp256k1_ios"
s.license          = 'MIT'
s.author           = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
s.source           = { :git => 'https://github.com/shamatar/secp256k1_ios.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'

s.module_name      = 'secp256k1_ios'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.10"
s.pod_target_xcconfig = {
	'OTHER_CFLAGS' => '-DHAVE_CONFIG_H=1',
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/secp256k1_ios/secp256k1_ios/"'
}
s.source_files = "secp256k1_ios/**/*.{h,c}", 
s.private_header_files = "secp256k1_ios/*.h", "secp256k1_ios/**/*.h"
s.public_header_files = "secp256k1_ios/include/secp256k1.h", "secp256k1_ios/include/secp256k1_recovery.h", "secp256k1_ios/include/secp256k1_ecdh.h"


end
