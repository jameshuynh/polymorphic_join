# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polymorphic_join/version'

Gem::Specification.new do |spec|
  spec.name          = 'polymorphic_join'
  spec.version       = PolymorphicJoin::VERSION
  spec.authors       = ['James Huynh']
  spec.email         = ['james@rubify.com']

  spec.summary       = 'This gem is used to do polymorphic join'
  spec.description   = 'This gem is used to do polymorphic join'
  spec.homepage      = 'https://rubify.com'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
