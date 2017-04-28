# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loggo_rails/version'

Gem::Specification.new do |spec|
  spec.name = 'loggo_rails'
  spec.version = LoggoRails::VERSION

  spec.summary = 'Simple sync logging with a Log-Go service for Rails Applications'
  spec.description = 'Log-GO is a centralized Log Service, high availability and scalable Write in GO. This projet should '

  spec.required_ruby_version = '>= 2.2.2'
  spec.required_rubygems_version = '>= 1.8.11'

  spec.license = 'MIT'

  spec.authors = 'Welington Sampaio'
  spec.email = 'lelo@alboompro.com'
  spec.homepage = 'https://github.com/alboompro/loggo_rails'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '~> 5.0'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'rest-client', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
