require 'test_helper'

describe Sodium::Auth::HMACSHA256 do
  include SodiumTestHelpers

  subject { self.klass.new(self.key) }

  let(:klass)     { Sodium::Auth::HMACSHA256 }
  let(:primitive) { :hmacsha256 }

  let :constants do
    { :BYTES    => 32,
      :KEYBYTES => 32, }
  end

  let_64(:key)           { 'XMfWD8/yrcNDzJyGhxRIwi5tSGKf8D0ul9FyX/djvjg=' }
  let_64(:authenticator) { '6WDKvxKevcZts0Yc1HWGnylNYEpcxPO9tVtApEK8XWc=' }
  let_64(:plaintext)     { 'bWVzc2FnZQ==' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal self.primitive
  end

  it 'must have correct values for its constants' do
    self.constants.each_pair do |name, value|
      self.klass[name].must_equal value
    end
  end

  it 'must mint keys' do
    self.klass.key.bytesize.
      must_equal self.klass[:KEYBYTES]
  end

  it 'must generate authenticators' do
    self.klass.auth(
      self.key,
      self.plaintext
    ).to_s.must_equal self.authenticator

    self.subject.auth(
      self.plaintext
    ).to_s.must_equal self.authenticator
  end

  it 'must verify authenticators' do
    self.klass.verify(
      self.key,
      self.plaintext,
      self.authenticator
    ).must_equal true

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
