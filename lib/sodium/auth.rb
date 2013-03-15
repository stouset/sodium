require_relative '../sodium'

class Sodium::Auth
  extend Sodium::Delegate.for(self)

  def initialize(key)
    _verify_key_length!(key, self.class::KEYBYTES)

    self.key = key.to_str
  end

  def auth(message)
    Sodium::Util.buffer(self.class::BYTES).tap do |authenticator|
      self.nacl_impl(authenticator, message, message.length, key)
    end
  end

  def verify(message, authenticator)
    self.nacl_verify(authenticator, message, message.length, key)
  end

  protected

  attr_accessor :key

  private

  def _verify_key_length!(key, bytes)
    raise ArgumentError, "key must be #{bytes} bytes long" unless
      key.bytesize == bytes
  end
end
