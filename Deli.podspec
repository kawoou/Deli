Pod::Spec.new do |s|

  s.name              = 'Deli'
  s.version           = `cat version`
  s.summary           = 'Simple and easy DI Container'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage          = 'https://github.com/kawoou/Deli'
  s.authors           = { 'Jungwon An' => 'kawoou@kawoou.kr' }
  s.social_media_url  = 'http://fb.com/kawoou'
  s.source            = { :git => s.homepage + '.git', :tag => 'v' + s.version.to_s }

  s.source_files      = 'Sources/Deli/**/*.{swift}'
  s.frameworks        = 'Foundation'
  s.module_name       = 'Deli'
  s.requires_arc      = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'

  s.dependency 'DeliBinary', '~> ' + s.version.to_s
end
