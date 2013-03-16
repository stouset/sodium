require 'rake/clean'

LIBSODIUM_VERSION = '0.2'
LIBSODIUM_TARBALL = "libsodium-#{LIBSODIUM_VERSION}.tar.gz"
LIBSODIUM_DIGEST  = 'e99a6b69adc080a5acf6b8a49fdc74b61d6f3579b590e85c93446a8325dde100'
LIBSODIUM_PATH    = 'build/libsodium/src/libsodium/.libs'
LIBSODIUM_LIB     = 'libsodium.so'
LIBSODIUM         = "#{LIBSODIUM_PATH}/#{LIBSODIUM_LIB}"

namespace :sodium do
  directory 'build'

  file LIBSODIUM_TARBALL do
    sh "curl -O http://download.dnscrypt.org/libsodium/releases/#{LIBSODIUM_TARBALL}"

    if LIBSODIUM_DIGEST != Digest::SHA256.hexdigest(File.read(LIBSODIUM_TARBALL))
      rm LIBSODIUM_TARBALL
      raise "#{LIBSODIUM_TARBALL} failed checksum"
    end
  end

  file 'build/libsodium' => [:build, LIBSODIUM_TARBALL] do
    sh "tar xf #{LIBSODIUM_TARBALL}"
    mv "libsodium-#{LIBSODIUM_VERSION}", "build/libsodium"
  end

  file 'build/libsodium/Makefile' => 'build/libsodium' do
    sh 'cd build/libsodium && ./configure'
  end

  file "#{LIBSODIUM_PATH}/libsodium.a" => 'build/libsodium/Makefile' do
    sh 'cd build/libsodium && make'
  end

  file LIBSODIUM => "#{LIBSODIUM_PATH}/libsodium.a"

  task :compile => LIBSODIUM
end

CLEAN.add 'build'
CLEAN.add LIBSODIUM_TARBALL

CLOBBER.add LIBSODIUM
