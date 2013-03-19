require 'sodium'

class Sodium::Auth
  include Sodium::Delegate

  def self.key
    Sodium::Util.key self.implementation[:KEYBYTES]
  end

  def initialize(key)
    @key = self.class._key(key)
  end

  def auth(message)
    message       = self.class._message(message)
    authenticator = Sodium::Util.buffer self.implementation[:BYTES]

    self.implementation.nacl(authenticator, message, message.length, @key) or
      raise Sodium::CryptoError, 'failed to generate an authenticator'

    authenticator
  end

  def verify(message, authenticator)
    message       = self.class._message(message)
    authenticator = self.class._authenticator(authenticator)

    self.implementation.nacl_verify(authenticator, message, message.length, @key)
  end

  private

  def self._key(k)
    Sodium::Util.assert_length k.to_str, self.implementation[:KEYBYTES], 'key'
  end

  def self._authenticator(a)
    Sodium::Util.assert_length a.to_str, self.implementation[:BYTES], 'authenticator'
  end

  def self._message(m)
    m.to_str
  end
end
