require 'sodium'
require 'securerandom'

module Sodium::Util
  def self.key(length)
    SecureRandom.random_bytes(length)
  end

  def self.nonce(length)
    SecureRandom.random_bytes(length)
  end

  def self.buffer(length)
    (0.chr * length).tap do |s|
      s.force_encoding('BINARY') if s.respond_to?(:force_encoding)
    end
  end

  def self.pad(message, length)
    self.buffer(length) << message
  end

  def self.unpad(message, length)
    message.slice(length, message.bytesize - length)
  end

  def self.assert_length(string, length, name)
    raise Sodium::LengthError, "#{name} must be exactly #{length} bytes long" unless
      string.bytesize == length

    string
  end
end
