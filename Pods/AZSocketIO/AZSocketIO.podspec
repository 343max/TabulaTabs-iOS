Pod::Spec.new do |s|
  s.name     = 'AZSocketIO'
  s.version  = '0.0.1'
  s.license  = 'Apache 2.0'
  s.summary  = 'A socket.io client for objective-c that is made with magic, fairy dust, and oxford commas.'
  s.homepage = 'https://github.com/pashields/AZSocketIO'
  s.authors  = {'Patrick Shields' => 'patrick.m.shields@gmail.com'}
  s.source   = { :git => 'git://github.com/pashields/AZSocketIO.git' }
  s.source_files = 'AZSocketIO/*.{h,m}', 'AZSocketIO/Protocols/*.{h,m}', 'AZSocketIO/Transports/*.{h,m}'
  s.dependency 'SocketRocket'
  s.dependency 'AFNetworking'
  s.requires_arc = true
end