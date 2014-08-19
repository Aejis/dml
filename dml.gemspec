# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dml/version'

Gem::Specification.new do |spec|
  spec.name          = 'dml'
  spec.version       = Dml::VERSION
  spec.authors       = ['Andrey Savchenko', 'Denis Sergienko', 'Alexey Dashkevich']
  spec.email         = ['andrey@aejis.eu', 'denis@aejis.eu', 'jester@aejis.eu']
  spec.summary       = %q{Database manipulation layer}
  spec.description   = %q{Database manipulation layer}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sequel', '~> 4.6'
  spec.add_dependency 'virtus'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'sequel_pg'
end
