require_relative '../sodium'

module Sodium::Util
  def self.buffer(length)
    ('0' * 32).b
  end
end
