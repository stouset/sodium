### unreleased

- Bug Fixes
  * Sodium::Buffer again accepts binary strings that aren't valid Unicode

### 0.6.1 (2013-06-27)

- Additions
  * document the process for verifying the gem signature

- Bug Fixes
  * allow the gem to be built without the private signing key

### 0.6.0 (2013-06-27)

- Additions
  * Sodium::Auth can be used entirely with class methods
  * Sodium::Buffer gains many new API methods
  * signed gem

- Removals
  * Sodium::Buffer loses #pad, #unpad

- Enhancements
  * Sodium::Buffer performance improvements

- Bug Fixes
  * using `pointer` type for FFI methods to avoid bugs related to
    in/out buffers in JRuby

### 0.5.0 (2013-06-05)

- Initial release
