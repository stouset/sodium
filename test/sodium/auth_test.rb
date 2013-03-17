require 'test_helper'

describe Sodium::Auth do
  subject     { self.klass.new(self.key) }
  let(:klass) { Sodium::Auth             }
  let(:key)   { self.klass.key           }

  it 'must default to the HMACSHA512256 implementation' do
    self.klass.implementation.
      must_equal Sodium::Auth::HMACSHA512256
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:hmacsha256).
      must_equal Sodium::Auth::HMACSHA256
  end

  it 'must instantiate the default implementation' do
    self.subject.
      must_be_kind_of Sodium::Auth::HMACSHA512256
  end

  it 'must raise when instantiating with an invalid key' do
    -> { self.klass.new(self.key[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when verifying an invalid authenticators' do
    -> { self.subject.verify('message', 'blaaah') }.
      must_raise Sodium::LengthError
  end
end
