require 'pathname'

module Sodium::FFI::Memory
  extend FFI::Library

  ffi_lib Pathname.new(__FILE__).dirname.join(
    %{memory.#{RbConfig::MAKEFILE_CONFIG['DLEXT']}}
  )

  attach_function 'sodium_memxor', [:pointer, :pointer, :pointer, :size_t ], :void
  attach_function 'sodium_memput', [:pointer, :pointer, :size_t,  :size_t ], :void
end
