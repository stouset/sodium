require 'sodium/ffi'

module Sodium::FFI::Random
  extend FFI::Library

  ffi_lib 'sodium'

  attach_function 'randombytes_random',  [],                  :uint32
  attach_function 'randombytes_uniform', [:uint32],           :uint32
  attach_function 'randombytes_buf',     [:pointer, :size_t], :void
end
