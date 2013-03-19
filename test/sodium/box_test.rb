require 'test_helper'

describe Sodium::Box do
  subject       { self.klass.new(*self.keypair) }
  let(:klass)   { Sodium::Box }
  let(:keypair) { self.klass.keypair }

  it 'must default to the Curve22519XSalsa20Poly1305 implementation' do
    self.klass.implementation.
      must_equal Sodium::Box::Curve25519XSalsa20Poly1305
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:xyz).
      must_equal nil
  end

  it 'must instantiate the default implementation' do
    self.subject.
      must_be_kind_of Sodium::Box::Curve25519XSalsa20Poly1305
  end

  it 'must mint keypairs from the default implementation' do
    sodium_mock_default(self.klass) do |klass, mock|
      mock.expect :nacl_keypair, true, [ '', '' ]
      mock.expect :[],           0,    [:PUBLICKEYBYTES]
      mock.expect :[],           0,    [:SECRETKEYBYTES]


      sk, pk = klass.keypair

      sk.must_equal ''
      pk.must_equal ''
    end
  end

  it 'must raise when instantiating with an invalid keypair' do
    secret_key, public_key = self.keypair

    lambda { self.klass.new(secret_key[0..-2], public_key) }.
      must_raise Sodium::LengthError

    lambda { self.klass.new(secret_key, public_key[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when receiving an invalid nonce' do
    lambda { self.subject.box('message', self.subject.nonce[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when receiving an invalid shared key' do
    lambda { self.klass.afternm('key', 'message', self.subject.nonce) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when failing to generate keypairs' do
    sodium_stub_failure(self.klass, :nacl_keypair) do
      lambda { self.keypair }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to close a box' do
    sodium_stub_failure(self.klass, :nacl) do
      lambda { self.subject.box('message', self.subject.nonce) }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to open a box' do
    sodium_stub_failure(self.klass, :nacl_open) do
      lambda { self.subject.open('ciphertext', self.subject.nonce) }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to generate a shared key' do
    sodium_stub_failure(self.klass, :nacl_beforenm) do
      lambda { self.subject.beforenm }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to close a box with a shared key' do
    sodium_stub_failure(self.klass, :nacl_afternm) do
      lambda do
        key     = self.subject.beforenm
        nonce   = self.subject.nonce
        message = 'message'

        self.klass.afternm(key, message, nonce)
      end.must_raise Sodium::CryptoError
    end
  end

    it 'must raise when failing to open a box with a shared key' do
    sodium_stub_failure(self.klass, :nacl_open_afternm) do
      lambda do
        key        = self.subject.beforenm
        nonce      = self.subject.nonce
        ciphertext = 'ciphertext'

        self.klass.open_afternm(key, ciphertext, nonce)
      end.must_raise Sodium::CryptoError
    end
  end
end
