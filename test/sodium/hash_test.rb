require 'test_helper'

describe Sodium::Hash do
  let(:klass)     { Sodium::Hash }
  let(:plaintext) { 'message' }

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
      mock.expect :nacl, '', [ String, self.plaintext, self.plaintext.length ]

      klass.hash(self.plaintext).length.must_equal 0
    end
  end

  it 'must raise when failing to generate a hash' do
    sodium_stub_failure(self.klass, :nacl) do
      lambda { self.klass.hash(self.plaintext) }.
        must_raise Sodium::CryptoError
    end
  end
end
