# -*- encoding: utf-8 -*-
require File.expand_path('../lib/khoj/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jiren Patel"]
  gem.email         = ["jiren@joshsoftware.com"]
  gem.description   = %q{Elastic search client}
  gem.summary       = %q{Elastic search client}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "khoj"
  gem.require_paths = ["lib"]
  gem.version       = Khoj::VERSION
  gem.add_dependency('json', '>= 1.5.3')
  gem.add_dependency("httparty", ">= 0.7.8")

  gem.add_development_dependency('activesupport', '>= 3.0.0')
  gem.add_development_dependency('i18n')
end
