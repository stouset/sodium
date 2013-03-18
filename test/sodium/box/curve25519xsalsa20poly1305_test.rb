require 'test_helper'

describe Sodium::Box::Curve25519XSalsa20Poly1305 do
  subject { self.klass.new(self.secret_key, self.public_key) }

  let(:klass)      { Sodium::Box::Curve25519XSalsa20Poly1305 }
  let(:primitive)  { :curve25519xsalsa20poly1305 }

  let :constants do
    { :PUBLICKEYBYTES => 32,
      :SECRETKEYBYTES => 32,
      :BEFORENMBYTES  => 32,
      :NONCEBYTES     => 24,
      :ZEROBYTES      => 32,
      :BOXZEROBYTES   => 16,
      :MACBYTES       => 16, }
  end

  let(:secret_key) { Base64.decode64 'f52WNdyy0r1YA5NCGlcF+vJ5HPG8yfHwzn/HJSJzfQk=' }
  let(:public_key) { Base64.decode64 'es8h5AH9GGD7PF10D1txeHAFAB2UNc9OZF+JqFWE9y8=' }
  let(:shared_key) { Base64.decode64 'TTp8bQBhIuiiQ0plVcqS3Cj62i/IdAFnopx4t9di2Kg=' }
  let(:nonce)      { Base64.decode64 'i72xIDJ4tcHCOHGYAzI6PoiVm31PFVgx' }
  let(:ciphertext) { Base64.decode64 'lHhCSFzopX4z02nlIuInHe3hFwpHFdA=' }
  let(:plaintext)  { 'message' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal self.primitive
  end

  it 'must have correct values for its constants' do
    self.constants.each_pair do |name, value|
      self.klass[name].must_equal value
    end
  end

  it 'must mint secret keys' do
    self.klass.keypair[0].length.must_equal self.klass[:SECRETKEYBYTES]
  end

  it 'must mint public keys' do
    self.klass.keypair[1].length.must_equal self.klass[:PUBLICKEYBYTES]
  end

  it 'must generate closed boxes' do
    self.subject.box(
      self.plaintext,
      self.nonce
    ).must_equal self.ciphertext
  end

  it 'must open boxes' do
    self.subject.open(
      self.ciphertext,
      self.nonce
    ).must_equal self.plaintext
  end

  it 'must generate shared keys' do
    self.subject.beforenm.must_equal self.shared_key
  end

  it 'must generate closed boxes with shared keys' do
    self.subject.afternm(
      self.shared_key,
      self.plaintext,
      self.nonce
    ).must_equal self.ciphertext
  end

  it 'must open boxes with shared keys' do
    self.subject.open_afternm(
      self.shared_key,
      self.ciphertext,
      self.nonce
    ).must_equal self.plaintext
  end
end
