Pod::Spec.new do |s|
  s.name             = 'Tmaxbackend'
  s.version          = '1.0.0'
  s.summary          = 'Go Backend Engine Framework for iOS'
  s.homepage         = 'https://github.com/Fenglifang0114/ios_tmax_back'
  s.license          = { :type => 'MIT', :text => 'Copyright 2026' }
  s.author           = { 'Tmax' => 'tmax@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '13.0'
  s.vendored_frameworks = 'Tmaxbackend.xcframework'
end
