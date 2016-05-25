Pod::Spec.new do |s|
    s.name = 'MissionControl'
    s.version = '1.0.0'
    s.summary = 'Super powerfull remote config utility written in Swift (iOS, watchOS, tvOS, OSX)'

    s.homepage = 'http://appculture.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'appculture' => 'dev@appculture.com' }
    s.social_media_url = 'http://twitter.com/appculture_ag'

    s.ios.deployment_target = '8.0'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'
    s.osx.deployment_target = '10.10'

    s.source = { :git => 'https://github.com/appculture/MissionControl-iOS.git', :tag => s.version }
    s.source_files = 'Sources/*.swift'
end