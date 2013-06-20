Gem::Specification.new do |gem|
  gem.name    = 'sodium'
  gem.version = File.read('VERSION') rescue '0.0.0'

  gem.author = 'Stephen Touset'
  gem.email  = 'stephen@touset.org'

  gem.homepage    = 'https://github.com/stouset/sodium'
  gem.summary     = 'A Ruby binding to the easy-to-use high-speed crypto library libsodium'
  gem.description = 'A library for performing cryptography based on modern ciphers and protocols'

  gem.bindir      = 'bin'
  gem.files       = `git ls-files`               .split("\n")
  gem.executables = `git ls-files -- bin/*`      .split("\n").map {|e| File.basename(e) }
  gem.extensions  = `git ls-files -- ext/**/*.rb`.split("\n")
  gem.test_files  = `git ls-files -- spec/*`     .split("\n")

  gem.requirements << 'libsodium ~> 0.5'

  gem.add_dependency 'ffi', '~> 1'

  gem.add_development_dependency 'rake',     '~> 10'
  gem.add_development_dependency 'minitest', '~> 5'
  gem.add_development_dependency 'version',  '~> 1'
end
