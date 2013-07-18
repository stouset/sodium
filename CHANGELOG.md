### unreleased

- Additions
  * Sodium::Buffer#to_ptr added to replace #to_str
  * Sodium::Buffer#to_s added to replace #to_str

- Removals
  * Sodium::Buffer#to_str removed

- Bug Fixes
  * Potential data loss bug fixed. Sodium::Buffer can no longer be
    garbage collected (thus clearing its bytes) while a pointer to its
    bytes (from #to_ptr) is being held.

### 0.6.2 (2013-07-09)

- Additions
  * now actually distributed with a license! (MIT)

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
