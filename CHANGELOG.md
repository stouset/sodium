### (Unreleased)

- Additions
  * Sodium::Auth can be used entirely with class methods
  * Sodium::Buffer gains many new API methods

- Removals
  * Sodium::Buffer loses #pad, #unpad

- Enhancements
  * Sodium::Buffer performance improvements

- Bug Fixes
  * Using `pointer` type for FFI methods to avoid bugs related to
    in/out buffers in JRuby
