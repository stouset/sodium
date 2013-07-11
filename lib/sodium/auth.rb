require 'sodium'

class Sodium::Auth
  include Sodium::Delegate

  def self.key
    Sodium::Buffer.key self.implementation[:KEYBYTES]
  end

  def self.auth(key, message)
    key     = self._key(key)
    message = self._message(message)

    Sodium::Buffer.empty self.implementation[:BYTES] do |authenticator|
      self.implementation.nacl(
        authenticator.to_ptr,
        message      .to_ptr,
        message      .bytesize,
        key          .to_ptr
      ) or raise Sodium::CryptoError, 'failed to generate an authenticator'
    end
  end

  def self.verify(key, message, authenticator)
    key           = self._key(key)
    message       = self._message(message)
    authenticator = self._authenticator(authenticator)

    self.implementation.nacl_verify(
      authenticator.to_ptr,
      message      .to_ptr,
      message      .bytesize,
      key          .to_ptr
    )
  end

  def initialize(key)
    @key = self.class._key(key)
  end

  def auth(message)
    self.class.auth(@key, message)
  end

  def verify(message, authenticator)
    self.class.verify(@key, message, authenticator)
  end

  private

  def self._key(k)
    Sodium::Buffer.new k, self.implementation[:KEYBYTES]
  end

  def self._authenticator(a)
    Sodium::Buffer.new a, self.implementation[:BYTES]
  end

  def self._message(m)
    Sodium::Buffer.new(m)
  end
end
