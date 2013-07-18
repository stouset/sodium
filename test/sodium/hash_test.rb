require 'test_helper'

describe Sodium::Hash do
  include SodiumTestHelpers

  let(:klass)     { Sodium::Hash }

  let_64(:plaintext) { 'bWVzc2FnZQ==' }

  it 'must default to the SHA512 implementation' do
    self.klass.implementation.
      must_equal Sodium::Hash::SHA512
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:sha256).
      must_equal Sodium::Hash::SHA256
  end

  it 'must hash from the default implementation' do
    sodium_mock_default(self.klass) do |klass, mock|
      mock.expect :[],   0,  [ :BYTES ]
      mock.expect :nacl, '',
        [ FFI::Pointer, FFI::Pointer, self.plaintext.bytesize ]

      klass.hash(self.plaintext).to_s.must_equal ''
    end
  end

  it 'must raise when failing to generate a hash' do
    sodium_stub_failure(self.klass, :nacl) do
      lambda { self.klass.hash(self.plaintext) }.
        must_raise Sodium::CryptoError
    end
  end
end
