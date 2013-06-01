require 'test_helper'

describe Sodium::SecretBox::XSalsa20Poly1305 do
  subject { self.klass.new(self.key) }

  let(:klass)     { Sodium::SecretBox::XSalsa20Poly1305 }
  let(:primitive) { :xsalsa20poly1305 }

  let :constants do
    { :KEYBYTES     => 32,
      :NONCEBYTES   => 24,
      :ZEROBYTES    => 32,
      :BOXZEROBYTES => 16, }
  end

  let(:key)        { Base64.decode64 'MawdlglK6Ue29vbh+4vJb074PlFShQ6H1Cm6x2LiIP0=' }
  let(:nonce)      { Base64.decode64 'COwsnSeFSTeld0BQESGuuxyaCN4qeIyX' }
  let(:ciphertext) { Base64.decode64 'LrBMC/PJUh73zZKq+VY0kEXSH0EOaLU=' }
  let(:plaintext)  { 'message' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal self.primitive
  end

  it 'must have correct values for its constants' do
    self.constants.each_pair do |name, value|
      self.klass[name].must_equal value
    end
  end

  it 'must mint keys' do
    self.klass.key.length.must_equal self.klass[:KEYBYTES]
  end

  it 'must generate closed secret boxes' do
    self.subject.secret_box(
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
end
