[![Gem Version][gem-badge]][gem-url]
[![Build Status][travis-badge]][travis-url]
[![Dependency Status][gemnasium-badge]][gemnasium-url]
[![Code Climate][codeclimate-badge]][codeclimate-url]
[![Coverage Status][coveralls-badge]][coveralls-url]

sodium
======

`sodium` is a Ruby binding to the easy-to-use high-speed crypto library [`libsodium`][libsodium] (which itself is based on [Daniel J. Bernstein][djb]'s [`NaCl`][nacl]). `NaCl`'s goal, and thus this project's, is to provide all the core operations necessary to build high-level cryptographic tools.

`NaCl` improves upon existing libraries with improved security through tight coding standads, improved usability, and significantly boosted performance.

Why Sodium?
-----------

`sodium` exports the functions provided by `libsodium` in an object-oriented, Rubylike manner using a very thin [FFI][ffi] wrapper. It thus provides all the benefits of using the `libsodium` C library directly: simplicity, performance, and security.

This library is tightly focused on providing only modern primitives and operations, giving users as few ways as possible to shoot themselves in the foot. While *no* crypto library can prevent all classes of user error, this library at least attempts to minimize the possibility of known, easily-preventable types of user error such as the use of broken primitives, reliance on non-authenticated encryption modes, and composition of low-level primitives to perform tasks for which well-studied high-level operations already exist.

Libraries like [OpenSSL][openssl] pack in support for every cryptographic primitive, protocol, and operation under the sun. Many of these supported features are cryptographically broken and preserved only so developers can maintain compatibility with older software. This is explicitly *not* a goal of `sodium`. While we will provide migration paths away from any primitives discovered to be weak or broken, we will never introduce known-bad primitives (e.g., MD5 or SHA-1) or easy-to-fuck-up operations (e.g., CBC mode) for the sake of interoperability.

Security
--------

The underlying cryptographic functions and APIs have been designed, chosen, and implemented by professional cryptographers. `sodium` itself, however, has not. No guarantees are made about its security nor suitability for any particular purpose.

If believe you have discovered a security vulnerability in the `sodium` wrapper, contact me at `sodium (at) touset (dot) org`. Please encrypt your message using the project's [GPG key][gpg-key] (fingerprint: `1E71 12A4 9424 2358 F6C8 727D C947 F58B FFCE E0D7`).

Supported Platforms
-------------------

  * MRI 2.0
  * MRI 1.9.3
  * MRI 1.8.7 / REE
  * Rubinius 1.8 / 1.9
  * JRuby 1.8 / 1.9

Support for these platforms is automatically tested using [Travis CI][travis-ci].

Windows is also theoretically supported, but is as of yet completely untested. If `sodium` doesn't work for you on Windows (or any of the other supported platforms, for that matter), please submit a bug.

Installation
------------

### Dependencies

`sodium` depends on the [`libsodium`][libsodium] C library. It can be installed through [homebrew][homebrew] on OSX.

```sh
brew install libsodium
```

### Ruby Gem

`sodium` is distributed as a gem of the same name. You can simply install it through the `gem` command

```sh
gem install sodium
```

or install it through [`bundler`][bundler] by adding it to your `Gemfile` and bundling.

```ruby
echo gem 'sodium' >> Gemfile
bundle
```

### Signed Gem

As of version 0.6.0, the `sodium` gem will be signed with the project's public key. Ruby support for gem signatures is still in its infancy, but it is functional. You must install our certificate before you can verify the gem signature. Start by downloading the certificate and verifying its checksum.

```sh
curl -O https://raw.github.com/stouset/sodium/master/certs/sodium@touset.org.cert
shasum -a 256 --check <(echo "6c731e7872dbfab18397d62ee9aa1215ef186a5f31358d1f041faa49301624a6  sodium@touset.org.cert")
```

Of course, if our GitHub repo has been compromised, someone can easily replace both the key in the repo and the checksum in these directions. Like I said, gem signatures are still in their infancy. I encourage you to verify this signature through alternate channels. For instance, you can at least examine the git history of the file, and ensure it hasn't been changed (unless otherwise announced).

Once you have the certificate and have confirmed its correctness to your satisfaction, install it and then the gem.

```sh
gem cert -a sodium@touset.org.cert
gem install sodium -P HighSecurity
```

Verifying the gem signature when using [bundler][bundler] is substantially more difficult and will not be covered here until it becomes more practical. If you're curious, feel free to read the [relevant literature][bundler-gem-signatures].

Documentation
-------------

Full documentation can be found online at [RubyDoc][rubydoc-url]. Examples are provided for the following high-level operations:

  * [Secret-Key Encryption][example-symmetric-encryption]
  * [Secret-Key Message Authenticators][example-symmetric-authenticators]
  * [Public-Key Encryption][example-asymmetric-encryption]
  * [Public-Key Message Signatures][example-asymmetric-signatures]

Contributing
------------

Fork, commit, push. Submit pull request. When possible, try and follow existing coding conventions for the file you're editing.

[libsodium]: https://github.com/jedisct1/libsodium/
[djb]:       http://cr.yp.to/djb.html
[nacl]:      http://nacl.cr.yp.to/
[ffi]:       http://github.com/ffi/ffi
[openssl]:   http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html
[travis-ci]: https://travis-ci.org/stouset/sodium
[homebrew]:  http://mxcl.github.io/homebrew/
[bundler]:   http://gembundler.com/

[gem-badge]:         https://badge.fury.io/rb/sodium.png
[gem-url]:           https://badge.fury.io/rb/sodium
[travis-badge]:      https://travis-ci.org/stouset/sodium.png
[travis-url]:        https://travis-ci.org/stouset/sodium
[gemnasium-badge]:   https://gemnasium.com/stouset/sodium.png
[gemnasium-url]:     https://gemnasium.com/stouset/sodium
[codeclimate-badge]: https://codeclimate.com/github/stouset/sodium.png
[codeclimate-url]:   https://codeclimate.com/github/stouset/sodium
[coveralls-badge]:   https://coveralls.io/repos/stouset/sodium/badge.png?branch=master
[coveralls-url]:     https://coveralls.io/r/stouset/sodium
[rubydoc-badge]:     :(
[rubydoc-url]:       http://rubydoc.org/gems/sodium/frames

[example-symmetric-encryption]:     examples/TODO
[example-symmetric-authenticators]: examples/TODO
[example-asymmetric-encryption]:    examples/TODO
[example-asymmetric-signatures]:    examples/TODO

[gpg-key]: certs/sodium@touset.org.pub.gpg

[bundler-gem-signatures]: http://blog.meldium.com/home/2013/3/3/signed-rubygems-part
