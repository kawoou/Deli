Pod::Spec.new do |s|

  s.name              = 'Deli'
  s.version           = `cat version`
  s.summary           = 'Deli is an easy-to-use Dependency Injection Container that creates DI containers with all required registrations and corresponding factories.'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage          = 'https://github.com/kawoou/Deli'
  s.authors           = { 'Jungwon An' => 'kawoou@kawoou.kr' }
  s.social_media_url  = 'http://fb.com/kawoou'
  s.source            = { :git => s.homepage + '.git', :tag => 'v' + s.version.to_s }

  s.source_files      = 'Sources/Deli/**/*.{swift}'
  s.frameworks        = 'Foundation'
  s.module_name       = 'Deli'
  s.requires_arc      = true

  s.dependency 'DeliBinary', '~> ' + s.version.to_s
end