Pod::Spec.new do |s|
  s.name             = 'MUXSDKKaltura'

  s.version          = '0.1.0'
  s.source           = { :git => 'https://github.com/muxinc/mux-stats-sdk-kaltura.git',
                         :tag => "v#{s.version}" }

  s.summary          = 'The Mux Stats SDK for Kaltura'
  s.description      = 'The Mux Stats SDK connect with Kaltura player to perform analytics and QoS monitoring for video.'

  s.homepage         = 'https://mux.com'
  s.social_media_url = 'https://twitter.com/muxhq'

  s.license          = 'Apache 2.0'
  s.author           = { 'Mux' => 'ios-sdk@mux.com' }
  s.swift_version = '5.0'

  s.dependency 'Mux-Stats-Core', '~>3.5'
  s.dependency 'PlayKit', '~>3.21'

  s.source_files = 'MUXSDKKaltura/MUXSDKKaltura/*.swift'

  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'XCFramework/MUXSDKStats.xcframework'

  s.tvos.deployment_target = '9.0'
  s.tvos.vendored_frameworks = 'XCFramework/MUXSDKStats.xcframework'
end
