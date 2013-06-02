require 'sodium'

class Sodium::Hash
  include Sodium::Delegate

  def self.hash(message)
    message = _message(message)
    digest  = Sodium::Buffer.empty self.implementation[:BYTES]

    self.implementation.nacl(
      digest.to_str,
      message.to_str,
      message.to_str.bytesize
    ) or raise Sodium::CryptoError, 'failed to generate a hash for the message'

    digest
  end

  private

  def self._message(m)
    Sodium::Buffer.new m
  end
end
