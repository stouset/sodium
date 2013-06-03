module Sodium
  class Error       < ::StandardError; end
  class LengthError < Error;           end
  class CryptoError < Error;           end
  class MemoryError < Error;           end
end

require 'sodium/delegate'

require 'sodium/buffer'
require 'sodium/random'

require 'sodium/auth'
require 'sodium/box'
require 'sodium/hash'
require 'sodium/one_time_auth'
require 'sodium/secret_box'

require 'sodium/ffi'
