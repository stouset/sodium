require 'sodium'

class Sodium::Box
  include Sodium::Delegate

  def self.keypair
    public_key = Sodium::Util.buffer self.implementation[:PUBLICKEYBYTES]
    secret_key = Sodium::Util.buffer self.implementation[:SECRETKEYBYTES]

    self.implementation.nacl_keypair(public_key, secret_key) or
      raise Sodium::CryptoError, 'failed to generate a keypair'

    return secret_key, public_key
  end

  def self.afternm(shared_key, message, nonce)
    shared_key = _shared_key(shared_key)
    message    = _message(message)
    nonce      = _nonce(nonce)
    ciphertext = Sodium::Util.buffer(message.length)

    self.implementation.nacl_afternm(
      ciphertext,
      message, message.length,
      nonce,
      shared_key
    ) or raise Sodium::CryptoError, 'failed to close the box'

    Sodium::Util.unpad ciphertext, self.implementation[:BOXZEROBYTES]
  end

  def self.open_afternm(shared_key, ciphertext, nonce)
    shared_key = _shared_key(shared_key)
    ciphertext = _ciphertext(ciphertext)
    nonce      = _nonce(nonce)
    message    = Sodium::Util.buffer(ciphertext.length)

    self.implementation.nacl_open_afternm(
      message,
      ciphertext, ciphertext.length,
      nonce,
      shared_key
    ) or raise Sodium::CryptoError, 'failed to open the box'

    Sodium::Util.unpad message, self.implementation[:ZEROBYTES]
  end


  def initialize(secret_key, public_key)
    @secret_key = self.class._secret_key(secret_key)
    @public_key = self.class._public_key(public_key)
  end

  def nonce
    Sodium::Util.nonce self.implementation[:NONCEBYTES]
  end

  def box(message, nonce)
    message    = self.class._message(message)
    nonce      = self.class._nonce(nonce)
    ciphertext = Sodium::Util.buffer(message.length)

    self.implementation.nacl(
      ciphertext,
      message, message.length,
      nonce,
      @public_key,
      @secret_key
    ) or raise Sodium::CryptoError, 'failed to close the box'

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
      @public_key,
      @secret_key
    ) or raise Sodium::CryptoError, 'failed to open the box'

    Sodium::Util.unpad message, self.implementation[:ZEROBYTES]
  end

  def beforenm
    shared_key = Sodium::Util.buffer self.implementation[:BEFORENMBYTES]

    self.implementation.nacl_beforenm(
      shared_key, @public_key, @secret_key
    ) or raise Sodium::CryptoError, 'failed to create a shared key'

    shared_key
  end

  private

  def self._public_key(k)
    Sodium::Util.assert_length k.to_str, self.implementation[:PUBLICKEYBYTES], 'public key'
  end

  def self._secret_key(k)
    Sodium::Util.assert_length k.to_str, self.implementation[:SECRETKEYBYTES], 'secret key'
  end

  def self._shared_key(k)
    Sodium::Util.assert_length k.to_str, self.implementation[:BEFORENMBYTES], 'secret key'
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
