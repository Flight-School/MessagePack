Pod::Spec.new do |s|
  s.name                    = "MessagePack"
  s.version                 = "1.2.3"
  s.summary                 = "A MessagePack encoder and decoder for Codable types."
  s.homepage                = "https://github.com/Flight-School/MessagePack"
  s.license                 = "MIT"
  s.author                  = "Mattt (@mattt)"
  s.source                  = { :git => "https://github.com/Flight-School/MessagePack.git", :tag => "#{s.version}" }
  s.source_files            = "Sources", "Sources/**/*.swift"
  s.ios.deployment_target   = '8.0'
  s.osx.deployment_target   = '10.10'
  s.tvos.deployment_target  = '9.0'
end
