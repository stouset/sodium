require 'sodium'

class Sodium::Hash
  include Sodium::Delegate

  def self.hash(message)
    message = _message(message)

    Sodium::Buffer.empty self.implementation[:BYTES] do |digest|
      self.implementation.nacl(
        digest.to_str,
        message.to_str,
        message.to_str.bytesize
      ) or raise Sodium::CryptoError, 'failed to generate a hash for the message'
    end
  end

  private

  def self._message(m)
    Sodium::Buffer.new m
  end
end
