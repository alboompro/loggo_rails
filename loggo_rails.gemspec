# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loggo_rails/version'

Gem::Specification.new do |spec|
  spec.name = 'loggo_rails'
  spec.version = LoggoRails::VERSION
  spec.authors = ['Welington Sampaio']
  spec.email = ['lelo@alboompro.com']

  spec.summary = 'asdasdas'
  spec.description = 'Write a longer description or delete this line.'
  spec.homepage = 'http:/asdasd.asd/'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f)}
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 5.0.0'
  spec.add_dependency 'json', '>= 1.7.7'
  spec.add_dependency 'rest-client', '>= 1.6.7'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
