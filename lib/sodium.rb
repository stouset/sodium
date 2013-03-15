module Sodium
  class Error       < ::StandardError; end
  class LengthError < Error;           end
  class CryptoError < Error;           end
end

require_relative 'sodium/delegate'
require_relative 'sodium/util'

require_relative 'sodium/auth'
require_relative 'sodium/box'

require_relative 'sodium/na_cl'
