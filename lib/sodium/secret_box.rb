require 'sodium'

class Sodium::SecretBox
  include Sodium::Delegate

  def self.key
    Sodium::Buffer.key self.implementation[:KEYBYTES]
  end

  def initialize(key)
    @key = self.class._key(key)
  end

  def nonce
    Sodium::Buffer.nonce self.implementation[:NONCEBYTES]
  end

  def secret_box(message, nonce)
    message = self.class._message(message)
    nonce   = self.class._nonce(nonce)

    Sodium::Buffer.empty(message.bytesize) do |ciphertext|
      self.implementation.nacl(
        ciphertext .to_ptr,
        message    .to_ptr,
        message    .bytesize,
        nonce      .to_ptr,
        @key       .to_ptr
      ) or raise Sodium::CryptoError, 'failed to close the secret box'
    end.ldrop self.implementation[:BOXZEROBYTES]
  end

  def open(ciphertext, nonce)
    ciphertext = self.class._ciphertext(ciphertext)
    nonce      = self.class._nonce(nonce)

    Sodium::Buffer.empty(ciphertext.bytesize) do |message|
      self.implementation.nacl_open(
        message    .to_ptr,
        ciphertext .to_ptr,
        ciphertext .bytesize,
        nonce      .to_ptr,
        @key       .to_ptr
      ) or raise Sodium::CryptoError, 'failed to open the secret box'
    end.ldrop self.implementation[:ZEROBYTES]
  end

  private

  def self._key(k)
    Sodium::Buffer.new k, self.implementation[:KEYBYTES]
  end

  def self._message(m)
    Sodium::Buffer.lpad m, self.implementation[:ZEROBYTES]
  end

  def self._ciphertext(c)
    Sodium::Buffer.lpad c, self.implementation[:BOXZEROBYTES]
  end

  def self._nonce(n)
    Sodium::Buffer.new n, self.implementation[:NONCEBYTES]
  end
end
