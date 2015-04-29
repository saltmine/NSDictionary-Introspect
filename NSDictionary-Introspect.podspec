Pod::Spec.new do |s|
  s.name              = "NSDictionary-Introspect"
  s.version           = "0.1.0"
  s.summary           = "Objective-C Runtime Property Introspection"
  s.homepage          = "https://github.com/saltmine/NSDictionary-Introspect"
  s.license           = 'MIT'
  s.author            = { "Chamara Paul" => "chamara@keep.com" }
  s.source            = { :git => "https://github.com/saltmine/NSDictionary-Introspect.git", :tag => s.version.to_s }
  s.social_media_url  = 'https://twitter.com/chamwow'
  s.platform          = :ios, '7.0'
  s.requires_arc      = true
  s.source_files      = '*.{h,m}'
end
