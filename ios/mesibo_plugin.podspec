#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mesibo_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mesibo_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'mesibo'
  s.dependency 'mesibo-ui'
  s.dependency 'mesibo-calls'
  s.dependency 'mesibo-webrtc'
  s.static_framework = true
  s.platform = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
  
 
  
  # s.xcconfig = { 'OTHER_LDFLAGS' => '-framework mesibo' }
  # s.preserve_paths = 'mesibo.framework'
  # s.vendored_frameworks = 'mesibo.framework'
  # # s.libraries = 'sqlite3'
  # s.resource = 'mesibo.framework'
end
