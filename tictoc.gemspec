# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tictoc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jason Weathered']
  gem.email         = ['jason@jasoncodes.com']
  gem.summary       = %q{Report Tictoc timesheet summary by day}
  gem.homepage      = 'https://github.com/jasoncodes/tictoc'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'tictoc'
  gem.require_paths = ['lib']
  gem.version       = Tictoc::VERSION

  gem.add_dependency 'rb-appscript'
  gem.add_dependency 'i18n'
  gem.add_dependency 'activerecord', '~> 4.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'gem-release'
end
