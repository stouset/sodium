require 'sodium'

class Sodium::SecretBox
  include Sodium::Delegate

  def self.key
    Sodium::Util.key self.implementation[:KEYBYTES]
  end

  def initialize(key)
    @key = self.class._key(key)
  end

  def nonce
    Sodium::Util.nonce self.implementation[:NONCEBYTES]
  end

  def secret_box(message, nonce)
    message    = self.class._message(message)
    nonce      = self.class._nonce(nonce)
    ciphertext = Sodium::Util.buffer(message.length)

    self.implementation.nacl(
      ciphertext,
      message, message.length,
      nonce,
      @key
    ) or raise Sodium::CryptoError, 'failed to close the secret box'

    Sodium::Util.unpad ciphertext, self.implementation[:BOXZEROBYTES]
  end

  def open(ciphertext, nonce)
    ciphertext = self.class._ciphertext(ciphertext)
    nonce      = self.class._nonce(nonce)
    message    = Sodium::Util.buffer(ciphertext.length)

    self.implementation.nacl_open(
      message,
      ciphertext, ciphertext.length,
      nonce,
      @key
    ) or raise Sodium::CryptoError, 'failed to open the secret box'

    Sodium::Util.unpad message, self.implementation[:ZEROBYTES]
  end

  private

  def self._key(k)
    Sodium::Util.assert_length k.to_str, self.implementation[:KEYBYTES], 'key'
  end

  def self._message(m)
    Sodium::Util.pad m.to_str, self.implementation[:ZEROBYTES]
  end

  def self._ciphertext(c)
    Sodium::Util.pad c.to_str, self.implementation[:BOXZEROBYTES]
  end

  def self._nonce(n)
    Sodium::Util.assert_length n.to_str, self.implementation[:NONCEBYTES], 'nonce'
  end
end
