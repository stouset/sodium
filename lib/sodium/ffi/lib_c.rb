require 'sodium/ffi'

module Sodium::FFI::LibC
  extend FFI::Library

  ffi_lib FFI::Library::LIBC

  attach_function 'mlock', [:pointer, :size_t], :int
end
