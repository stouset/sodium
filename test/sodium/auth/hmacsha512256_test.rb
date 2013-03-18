require 'test_helper'

describe Sodium::Auth::HMACSHA512256 do
  subject { self.klass.new(self.key) }

  let(:klass)     { Sodium::Auth::HMACSHA512256 }
  let(:primitive) { :hmacsha512256 }

  let :constants do
    { :BYTES    => 32,
      :KEYBYTES => 32, }
  end

  let(:key)           { Base64.decode64 'XMfWD8/yrcNDzJyGhxRIwi5tSGKf8D0ul9FyX/djvjg=' }
  let(:authenticator) { Base64.decode64 '6BN5+HNq0F8skQKkta+CLiBJ7mrrJaGw3G2J7jMT2qA=' }
  let(:plaintext)     { 'message' }

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

  it 'must generate authenticators' do
    self.subject.auth(
      self.plaintext
    ).must_equal self.authenticator
  end

  it 'must verify authenticators' do
    self.subject.verify(
      self.plaintext,
      self.authenticator
    ).must_equal true
  end

  it 'must not verify forged authenticators' do
    self.subject.verify(
      self.plaintext,
      self.authenticator.succ
    ).must_equal false
  end
end
