require 'sodium'

module Sodium::Random
  @mutex = Mutex.new

  def self.synchronize(&block)
    @mutex.synchronize(&block)
  end

  def self.bytes(size)
    Sodium::Buffer.empty(size) do |buffer|
      self.synchronize do
        Sodium::FFI::Random.randombytes_buf(
          buffer.to_str,
          buffer.bytesize
        )
      end
    end
  end

  def self.integer(max = 2 ** 32 - 1)
    self.synchronize do
      Sodium::FFI::Random.randombytes_uniform(max)
    end
  end
end
