Gem::Specification.new do |s|
  s.specification_version = 3

  s.name = 'nobrainer-references'
  s.version = '0.1.0'
  s.date = '2017-12-17'

  s.summary = "NoBrainer support for reference types"
  s.description = ""
  s.homepage = 'https://github.com/CodeMonkeySteve/nobrainer-references'
  s.email = 'steve@finagle.org'
  s.authors = ["Steve Sloan"]

  s.files = [
    'LICENSE',
    'README.md',
  ] + Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']

  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency 'nobrainer', '~> 0.44'
end
