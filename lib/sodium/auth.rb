require_relative '../sodium'

class Sodium::Auth
  extend Sodium::Delegate.for(self)

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
    authenticator = Sodium::Util.buffer(self.class::BYTES)
    message       = _message(message)

    self.nacl_impl(authenticator, message, message.length, @key)

    authenticator
  end

  def verify(message, authenticator)
    authenticator = _authenticator(authenticator)
    message       = _message(message)

    self.nacl_verify(authenticator, message, message.length, @key)
  end

  def primitive
    self.class::PRIMITIVE
  end

  private

  def _key(k)
    Sodium::Util.ensure_length(k.to_str, self.class::KEYBYTES, 'key')
  end

  def _authenticator(a)
    Sodium::Util.ensure_length(a.to_str, self.class::KEYBYTES, 'authenticator')
  end

  def _message(m)
    m.to_str
  end
end
