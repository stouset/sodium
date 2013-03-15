require_relative '../sodium'

module Sodium::Util
  def self.buffer(length)
    (0.chr * length).b
  end

  def self.ensure_length(string, length, name)
    raise ArgumentError, "#{name} must be exactly #{length} bytes long" unless
      string.bytesize == length

    string
  end
end
