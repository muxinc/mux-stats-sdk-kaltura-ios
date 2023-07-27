Pod::Spec.new do |s|
  s.name             = 'Mux-Stats-Kaltura'

  s.version          = '2.1.0'
  s.source           = { :git => 'https://github.com/muxinc/mux-stats-sdk-kaltura.git',
                         :tag => "v#{s.version}" }

  s.summary          = 'The Mux Stats SDK for Kaltura'
  s.description      = 'The Mux Stats SDK connect with Kaltura player to perform analytics and QoS monitoring for video.'

  s.homepage         = 'https://mux.com'
  s.social_media_url = 'https://twitter.com/muxhq'

  s.license          = 'Apache 2.0'
  s.author           = { 'Mux' => 'ios-sdk@mux.com' }
  s.swift_version = '5.7'

  s.dependency 'Mux-Stats-Core', '~>4.5.2'
  s.dependency 'PlayKit', '~>3.27'

  s.frameworks = 'AVFoundation', 'Network', 'SystemConfiguration'

  s.ios.deployment_target = '11.0'
  s.ios.vendored_frameworks = 'XCFramework/MUXSDKKaltura.xcframework'

  s.tvos.deployment_target = '11.0'
  s.tvos.vendored_frameworks = 'XCFramework/MUXSDKKaltura.xcframework'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
