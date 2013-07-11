require 'sodium'

class Sodium::OneTimeAuth
  include Sodium::Delegate

  def self.key
    Sodium::Buffer.key self.implementation[:KEYBYTES]
  end

  def initialize(key)
    @key = self.class._key(key)
  end

  def one_time_auth(message)
    message = self.class._message(message)

    Sodium::Buffer.empty self.implementation[:BYTES] do |authenticator|
      self.implementation.nacl(
        authenticator.to_ptr,
        message      .to_ptr,
        message      .bytesize,
        @key         .to_ptr
      ) or raise Sodium::CryptoError, 'failed to generate an authenticator'
    end
  end

  def verify(message, authenticator)
    message       = self.class._message(message)
    authenticator = self.class._authenticator(authenticator)

    self.implementation.nacl_verify(
      authenticator.to_ptr,
      message      .to_ptr,
      message      .bytesize,
      @key         .to_ptr
    )
  end

  private

  def self._key(k)
    Sodium::Buffer.new k, self.implementation[:KEYBYTES]
  end

  def self._authenticator(a)
    Sodium::Buffer.new a, self.implementation[:BYTES]
  end

  def self._message(m)
    Sodium::Buffer.new m
  end
end
