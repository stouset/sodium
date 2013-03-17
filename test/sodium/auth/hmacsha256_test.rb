require 'test_helper'

describe Sodium::Auth::HMACSHA256 do
  subject { self.klass.new(self.key) }

  let(:klass)         { Sodium::Auth::HMACSHA256 }
  let(:key)           { Base64.decode64 'XMfWD8/yrcNDzJyGhxRIwi5tSGKf8D0ul9FyX/djvjg=' }
  let(:authenticator) { Base64.decode64 '6WDKvxKevcZts0Yc1HWGnylNYEpcxPO9tVtApEK8XWc=' }
  let(:plaintext)     { 'message' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal :hmacsha256
  end

  it '::BYTES must be correct' do
    self.klass::BYTES.must_equal 32
  end

  it '::KEYBYTES must be correct' do
    self.klass::KEYBYTES.must_equal 32
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
end
