# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dm-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name             = "ardm-rails"
  gem.version          = DataMapper::Rails::VERSION

  gem.authors          = ['Martin Emde', 'Martin Gamsjaeger (snusnu)', 'Dan Kubb' ]
  gem.email            = ['me@martinemde.com', 'gamsnjaga@gmail.com' ]
  gem.summary          = "Ardm fork of dm-rails"
  gem.description      = "DataMapper rails adapter"
  gem.homepage         = "https://github.com/ar-dm/ardm-rails"
  gem.license          = 'MIT'

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = ["LICENSE", "README.md"]
  gem.require_paths    = ["lib"]

  gem.add_runtime_dependency 'ardm-core',         '~> 1.2'
  gem.add_runtime_dependency 'ardm-active_model', '~> 1.3'
  gem.add_runtime_dependency 'actionpack',        '~> 4.0'
  gem.add_runtime_dependency 'railties',          '~> 4.0'

  gem.add_development_dependency 'rake',      '~> 10.0'
  gem.add_development_dependency 'rspec',     '~> 2.0'
end
