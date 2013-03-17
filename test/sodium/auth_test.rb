require 'test_helper'

describe Sodium::Auth do
  let(:klass) { Sodium::Auth   }
  let(:key)   { self.klass.key }

  it 'must default to the HMACSHA512256 implementation' do
    self.klass.implementation.
      must_equal Sodium::Auth::HMACSHA512256
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:hmacsha256).
      must_equal Sodium::Auth::HMACSHA256
  end

  it 'must instantiate the default implementation' do
    self.klass.new(self.key).
      must_be_kind_of Sodium::Auth::HMACSHA512256
  end
end
