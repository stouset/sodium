require 'test_helper'

describe Sodium::Sign do
  include SodiumTestHelpers

  subject       { self.klass.new(self.keypair.first) }
  let(:klass)   { Sodium::Sign }
  let(:keypair) { self.klass.keypair }

  it 'must default to the Ed25519 implementation' do
    self.klass.implementation.
      must_equal Sodium::Sign::Ed25519
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:xyz).
      must_equal nil
  end

  it 'must instantiate the default implementation' do
    self.subject.
      must_be_kind_of Sodium::Sign::Ed25519
  end

  it 'must mint keys from the default implementation' do
    sodium_mock_default(self.klass) do |klass, mock|
      mock.expect :nacl_keypair, true, [ FFI::Pointer, FFI::Pointer]
      mock.expect :[],           0,    [:PUBLICKEYBYTES]
      mock.expect :[],           0,    [:SECRETKEYBYTES]

      sk, pk = klass.keypair

      sk.to_s.must_equal ''
      pk.to_s.must_equal ''
    end
  end

  it 'must raise when instantiating with an invalid key' do
    secret_key = self.keypair.first

    lambda { self.klass.new(secret_key.to_s[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when failing to generate keypairs' do
    sodium_stub_failure(self.klass, :nacl_keypair) do
      lambda { self.keypair }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to sign a message' do
    sodium_stub_failure(self.klass, :nacl) do
      lambda { self.subject.sign('message') }.
        must_raise Sodium::CryptoError
    end
  end
end
