Gem::Specification.new do |gem|
  gem.name    = 'sodium'
  gem.version = '0.0.0'

  gem.author = 'Stephen Touset'
  gem.email  = 'stephen@touset.org'

  gem.homepage    = 'https://github.com/stouset/sodium'
  gem.summary     = %{TBD}
  gem.description = %{TBD}

  gem.bindir      = 'bin'
  gem.files       = `git ls-files`            .split("\n")
  gem.extensions  = `git ls-files -- ext/*.rb`.split("\n")
  gem.executables = `git ls-files -- bin/*`   .split("\n").map {|e| File.basename(e) }
  gem.test_files  = `git ls-files -- spec/*`  .split("\n")

  gem.add_dependency 'ffi'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
end
