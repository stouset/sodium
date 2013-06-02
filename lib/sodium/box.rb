require 'sodium'

class Sodium::Box
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

  def self.afternm(shared_key, message, nonce)
    shared_key = _shared_key(shared_key)
    message    = _message(message)
    nonce      = _nonce(nonce)
    ciphertext = Sodium::Buffer.empty(message.bytesize)

    self.implementation.nacl_afternm(
      ciphertext.to_str,
      message.to_str,
      message.to_str.bytesize,
      nonce.to_str,
      shared_key.to_str
    ) or raise Sodium::CryptoError, 'failed to close the box'

    ciphertext.unpad self.implementation[:BOXZEROBYTES]
  end

  def self.open_afternm(shared_key, ciphertext, nonce)
    shared_key = _shared_key(shared_key)
    ciphertext = _ciphertext(ciphertext)
    nonce      = _nonce(nonce)
    message    = Sodium::Buffer.empty(ciphertext.bytesize)

    self.implementation.nacl_open_afternm(
      message.to_str,
      ciphertext.to_str,
      ciphertext.to_str.bytesize,
      nonce.to_str,
      shared_key.to_str
    ) or raise Sodium::CryptoError, 'failed to open the box'

    message.unpad self.implementation[:ZEROBYTES]
  end


  def initialize(secret_key, public_key)
    @secret_key = self.class._secret_key(secret_key)
    @public_key = self.class._public_key(public_key)
  end

  def nonce
    Sodium::Buffer.nonce self.implementation[:NONCEBYTES]
  end

  def box(message, nonce)
    message    = self.class._message(message)
    nonce      = self.class._nonce(nonce)
    ciphertext = Sodium::Buffer.empty(message.bytesize)

    self.implementation.nacl(
      ciphertext.to_str,
      message.to_str,
      message.to_str.bytesize,
      nonce.to_str,
      @public_key.to_str,
      @secret_key.to_str
    ) or raise Sodium::CryptoError, 'failed to close the box'

    ciphertext.unpad self.implementation[:BOXZEROBYTES]
  end

  def open(ciphertext, nonce)
    ciphertext = self.class._ciphertext(ciphertext)
    nonce      = self.class._nonce(nonce)
    message    = Sodium::Buffer.empty(ciphertext.bytesize)

    self.implementation.nacl_open(
      message.to_str,
      ciphertext.to_str,
      ciphertext.to_str.bytesize,
      nonce.to_str,
      @public_key.to_str,
      @secret_key.to_str
    ) or raise Sodium::CryptoError, 'failed to open the box'

    message.unpad self.implementation[:ZEROBYTES]
  end

  def beforenm
    shared_key = Sodium::Buffer.empty self.implementation[:BEFORENMBYTES]

    self.implementation.nacl_beforenm(
      shared_key.to_str,
      @public_key.to_str,
      @secret_key.to_str
    ) or raise Sodium::CryptoError, 'failed to create a shared key'

    shared_key
  end

  private

  def self._public_key(k)
    Sodium::Buffer.new k, self.implementation[:PUBLICKEYBYTES]
  end

  def self._secret_key(k)
    Sodium::Buffer.new k, self.implementation[:SECRETKEYBYTES]
  end

  def self._shared_key(k)
    Sodium::Buffer.new k, self.implementation[:BEFORENMBYTES]
  end

  def self._message(m)
    Sodium::Buffer.new(m).pad self.implementation[:ZEROBYTES]
  end

  def self._ciphertext(c)
    Sodium::Buffer.new(c).pad self.implementation[:BOXZEROBYTES]
  end

  def self._nonce(n)
    Sodium::Buffer.new n, self.implementation[:NONCEBYTES]
  end
end
