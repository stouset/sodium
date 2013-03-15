require_relative '../sodium'

class Sodium::Auth
  include Sodium::Delegate.for(self)

  def self.auth(key, message)
    self.new(key).auth(message)
  end

  def self.verify(key, message, authenticator)
    self.new(key).verify(message, authenticator)
  end

  def initialize(key)
    @key = _key(key)
  end

  def auth(message)
    message       = _message(message)
    authenticator = Sodium::Util.buffer(self.class::BYTES)

    self.implementation.nacl(authenticator, message, message.length, @key)

    authenticator
  end

  def verify(message, authenticator)
    message       = _message(message)
    authenticator = _authenticator(authenticator)

    self.implementation.nacl_verify(authenticator, message, message.length, @key)
  end

  private

  def _key(k)
    Sodium::Util.assert_length(k.to_str, self.implementation::KEYBYTES, 'key')
  end

  def _authenticator(a)
    Sodium::Util.assert_length(a.to_str, self.implementation::KEYBYTES, 'authenticator')
  end

  def _message(m)
    m.to_str
  end
end
