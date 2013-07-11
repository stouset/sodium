require 'test_helper'

describe Sodium::SecretBox do
  include SodiumTestHelpers

  subject     { self.klass.new(self.key) }
  let(:klass) { Sodium::SecretBox }
  let(:key)   { self.klass.key }

  it 'must default to the XSalsa20Poly1305 implementation' do
    self.klass.implementation.
      must_equal Sodium::SecretBox::XSalsa20Poly1305
  end

  it 'must allow access to alternate implementations' do
    self.klass.implementation(:xyz).
      must_equal nil
  end

  it 'must instantiate the default implementation' do
    self.subject.
      must_be_kind_of Sodium::SecretBox::XSalsa20Poly1305
  end

  it 'must mint keys from the default implmentation' do
    sodium_mock_default(self.klass) do |klass, mock|
      mock.expect :[], 0, [:KEYBYTES]

      klass.key.to_s.must_equal ''
    end
  end

  it 'must raise when instantiating with an invalid key' do
    lambda { self.klass.new(self.key.to_s[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when receiving an invalid nonce' do
    lambda { self.subject.secret_box('message', self.subject.nonce.to_s[0..-2]) }.
      must_raise Sodium::LengthError
  end

  it 'must raise when failing to close a box' do
    sodium_stub_failure(self.klass, :nacl) do
      lambda { self.subject.secret_box('message', self.subject.nonce) }.
        must_raise Sodium::CryptoError
    end
  end

  it 'must raise when failing to open a box' do
    sodium_stub_failure(self.klass, :nacl_open) do
      lambda { self.subject.open('ciphertext', self.subject.nonce) }.
        must_raise Sodium::CryptoError
    end
  end
end
