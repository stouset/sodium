require 'sodium'

module Sodium::Random
  def self.bytes(size)
    Sodium::Buffer.empty(size) do |buffer|
      Sodium::FFI::Random.randombytes_buf(
        buffer.to_str,
        buffer.bytesize
      )
    end
  end

  def self.integer(max = 2 ** 32 - 1)
    Sodium::FFI::Random.randombytes_uniform(max)
  end
end
