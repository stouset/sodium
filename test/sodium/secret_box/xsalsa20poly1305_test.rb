require 'test_helper'

describe Sodium::SecretBox::XSalsa20Poly1305 do
  include SodiumTestHelpers

  subject { self.klass.new(self.key) }

  let(:klass)     { Sodium::SecretBox::XSalsa20Poly1305 }
  let(:primitive) { :xsalsa20poly1305 }

  let :constants do
    { :KEYBYTES     => 32,
      :NONCEBYTES   => 24,
      :ZEROBYTES    => 32,
      :BOXZEROBYTES => 16, }
  end

  let_64(:key)        { 'MawdlglK6Ue29vbh+4vJb074PlFShQ6H1Cm6x2LiIP0=' }
  let_64(:nonce)      { 'COwsnSeFSTeld0BQESGuuxyaCN4qeIyX' }
  let_64(:ciphertext) { 'LrBMC/PJUh73zZKq+VY0kEXSH0EOaLU=' }
  let_64(:plaintext)  { 'bWVzc2FnZQ==' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal self.primitive
  end

  it 'must have correct values for its constants' do
    self.constants.each_pair do |name, value|
      self.klass[name].must_equal value
    end
  end

  it 'must mint keys' do
    self.klass.key.bytesize.must_equal self.klass[:KEYBYTES]
  end

  it 'must generate closed secret boxes' do
    self.subject.secret_box(
      self.plaintext,
      self.nonce
    ).to_s.must_equal self.ciphertext
  end

  it 'must open boxes' do
    self.subject.open(
      self.ciphertext,
      self.nonce
    ).to_s.must_equal self.plaintext
  end
end
