Pod::Spec.new do |s|
  s.name             = 'Mux-Stats-Kaltura'

  s.version          = '4.0.0'
  s.source           = { :git => 'https://github.com/muxinc/mux-stats-sdk-kaltura.git',
                         :tag => "v#{s.version}" }
  s.module_name      = 'MUXSDKStatsKaltura'

  s.summary          = 'The Mux Stats SDK for Kaltura'
  s.description      = 'The Mux Stats SDK connect with Kaltura player to perform analytics and QoS monitoring for video.'

  s.homepage         = 'https://mux.com'
  s.social_media_url = 'https://twitter.com/muxhq'

  s.license          = 'Apache 2.0'
  s.author           = { 'Mux' => 'ios-sdk@mux.com' }
  s.swift_version    = '5.9'

  s.dependency 'Mux-Stats-Core', '~>5.0.1'
  s.dependency 'PlayKit', '~>3.28.0'

  s.frameworks = 'AVFoundation', 'Network', 'CoreMedia'

  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'

  s.resource_bundles = {'MUXSDKStatsKaltura' => ['Sources/MUXSDKStatsKaltura/PrivacyInfo.xcprivacy']}

  s.source_files = 'Sources/MUXSDKStatsKaltura/**/*'
end
