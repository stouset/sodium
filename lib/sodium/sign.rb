require 'sodium'

class Sodium::Sign
  include Sodium::Delegate

  def self.keypair
    public_key = Sodium::Buffer.empty self.implementation[:PUBLICKEYBYTES]
    secret_key = Sodium::Buffer.empty self.implementation[:SECRETKEYBYTES]

    self.implementation.nacl_keypair(
      public_key.to_str,
      secret_key.to_str
    ) or raise Sodium::CryptoError, 'failed to generate a keypair'

    return secret_key, public_key
  end

  def self.open(key, signature)
    key       = self._public_key(key)
    signature = self._signature(signature)
    message   = Sodium::Buffer.empty(signature.bytesize)
    mlen      = FFI::MemoryPointer.new(:ulong_long, 1, true)

    self.implementation.nacl_open(
      message.to_str,
      mlen,
      signature.to_str,
      signature.to_str.bytesize,
      key.to_str
    ) or raise Sodium::CryptoError, 'failed to open the signature'

    Sodium::Buffer.new message.to_str.slice(0, mlen.read_ulong_long)
  end

  def initialize(key)
    @key = self.class._secret_key(key)
  end

  def sign(message)
    message   = self.class._message(message)
    signature = Sodium::Buffer.empty(message.bytesize + self.implementation[:BYTES])
    slen      = FFI::MemoryPointer.new(:ulong_long, 1, true)

    self.implementation.nacl(
      signature.to_str,
      slen,
      message.to_str,
      message.to_str.bytesize,
      @key.to_str
    ) or raise Sodium::CryptoError, 'failed to generate signature'

    Sodium::Buffer.new signature.to_str.slice(0, slen.read_ulong_long)
  end

  private

  def self._public_key(k)
    Sodium::Buffer.new k, self.implementation[:PUBLICKEYBYTES]
  end

  def self._secret_key(k)
    Sodium::Buffer.new k, self.implementation[:SECRETKEYBYTES]
  end

  def self._message(m)
    Sodium::Buffer.new m
  end

  def self._signature(s)
    Sodium::Buffer.new s
  end
end
