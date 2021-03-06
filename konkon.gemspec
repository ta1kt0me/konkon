# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'konkon/version'

Gem::Specification.new do |spec|
  spec.name          = "konkon"
  spec.version       = Konkon::VERSION
  spec.authors       = ["ta1kt0me"]
  spec.email         = ["p.wadachi@gmail.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/ta1kt0me/konkon"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["konkon-attendee", "konkon-member"]
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'poltergeist'
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug"
end
