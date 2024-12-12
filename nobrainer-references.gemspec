require_relative 'lib/no_brainer/references/version'

Gem::Specification.new do |s|
  s.specification_version = 3

  s.name = 'nobrainer-references'
  s.version = NoBrainer::References::VERSION
  s.summary = "NoBrainer support for model references"
  s.description = ""
  s.homepage = 'https://github.com/CodeMonkeySteve/nobrainer-references'
  s.email = 'steve@finagle.org'
  s.authors = ["Steve Sloan"]
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.7.0'

  s.files = %w[LICENSE README.md] + Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'nobrainer', '~> 0.44'
end
