Gem::Specification.new do |s|
  s.name         = 'xotools'
  s.version      = '0.0.1'
  s.date         = '2014-02-12'
  s.summary      = "Xecko Tools"
  s.description  = "Library and utilities from Xecko LLC"
  s.authors      = ["Steve Baker"]
  s.email        = 'steve@xecko.com'
  s.files        = Dir.glob("{bin,lib,doc}/**/*")
  s.executables  = ['mnt', 'xolink']
  s.require_path = 'lib'
  s.homepage     = 'https://github.com/tektsu/xotools'
  s.license      = 'MIT'
end