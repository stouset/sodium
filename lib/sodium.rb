module Sodium
  class Error       < ::StandardError; end
  class LengthError < Error;           end
  class CryptoError < Error;           end
end

require 'sodium/delegate'
require 'sodium/util'

require 'sodium/auth'
require 'sodium/box'
require 'sodium/hash'

require 'sodium/na_cl'
