require_relative '../sodium'

class Sodium::Box
  include Sodium::Delegate

  def self.keypair
    public_key = Sodium::Util.buffer(self.implementation::PUBLICKEYBYTES)
    secret_key = Sodium::Util.buffer(self.implementation::SECRETKEYBYTES)

    self.implementation.nacl_keypair(public_key, secret_key) or
      raise Sodium::CryptoError, 'failed to generate a keypair'

    return secret_key, public_key
  end

  def initialize(secret_key, public_key)
    @secret_key = _secret_key(secret_key)
    @public_key = _public_key(public_key)
  end

  def box(message, nonce)
    message    = _message(message)
    nonce      = _nonce(nonce)
    ciphertext = Sodium::Util.buffer(message.length)

    self.implementation.nacl(
      ciphertext,
      message, message.length,
      nonce,
      @public_key,
      @secret_key
    ) or raise Sodium::CryptoError, 'failed to close the box'

    Sodium::Util.unpad(ciphertext, self.implementation::BOXZEROBYTES)
  end

  def open(ciphertext, nonce)
    ciphertext = _ciphertext(ciphertext)
    nonce      = _nonce(nonce)
    message    = Sodium::Util.buffer(ciphertext.length)

    self.implementation.nacl_open(
      message,
      ciphertext, ciphertext.length,
      nonce,
      @public_key,
      @secret_key
    ) or raise Sodium::CryptoError, 'failed to open the box'

    Sodium::Util.unpad(message, self.implementation::ZEROBYTES)
  end

  private

  def _public_key(k)
    Sodium::Util.assert_length(k.to_str, self.implementation::PUBLICKEYBYTES, 'public key')
  end

  def _secret_key(k)
    Sodium::Util.assert_length(k.to_str, self.implementation::SECRETKEYBYTES, 'secret key')
  end

  def _message(m)
    Sodium::Util.pad(m.to_str, self.implementation::ZEROBYTES)
  end

  def _ciphertext(c)
    Sodium::Util.pad(c.to_str, self.implementation::BOXZEROBYTES)
  end

  def _nonce(n)
    Sodium::Util.assert_length(n.to_str, self.implementation::NONCEBYTES, 'nonce')
  end
end
