# -*- encoding: utf-8 -*-
require File.expand_path('../lib/devise-basecamper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["JD Hendrickson"]
  gem.email         = ["jd@digitalopera.com"]
  gem.description   = %q{Implement basecamp style subdomain authentication with support for multiple users under a single subdomain scoped account.}
  gem.summary       = %q{Implement basecamp style subdomain authentication}
  gem.homepage      = "https://github.com/digitalopera/devise-basecamper"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "devise-basecamper"
  gem.require_paths = ["lib"]
  gem.version       = Devise::Basecamper::VERSION

  gem.add_dependency('orm_adapter', '~> 0.1.0')
  gem.add_dependency('devise', '~> 2.1.0')
end
