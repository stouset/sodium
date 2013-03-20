require 'sodium'

class Sodium::Hash
  include Sodium::Delegate

  def self.hash(message)
    message = _message(message)
    digest  = Sodium::Util.buffer self.implementation[:BYTES]

    self.implementation.nacl(digest, message, message.length) or
      raise Sodium::CryptoError, 'failed to generate a hash for the message'

    digest
  end

  private

  def self._message(m)
    m.to_str
  end
end
