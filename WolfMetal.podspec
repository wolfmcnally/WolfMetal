Pod::Spec.new do |s|
  s.name             = 'WolfMetal'
  s.version          = '1.0.1'
  s.summary          = 'Utilities and conveniences for Metal for iOS, macOS, and tvOS.'

  s.description      = <<-DESC
Utilities and conveniences for Metal for iOS, macOS, and tvOS. Currently the main thing included is AngularGradientShader.
                       DESC

  s.homepage         = 'https://github.com/wolfmcnally/WolfMetal'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wolfmcnally' => 'wolf@wolfmcnally.com' }
  s.source           = { :git => 'https://github.com/wolfmcnally/WolfMetal.git', :tag => s.version.to_s }

  s.swift_version = '5.0'

  s.source_files = 'Sources/WolfMetal/**/*'

  s.ios.deployment_target = '9.3'
  s.macos.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'

  s.frameworks = 'Metal', 'CoreGraphics'

  s.dependency 'WolfGraphics'
end
