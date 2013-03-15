require_relative '../../test_helper'

describe Sodium::Auth::HMACSHA512256 do
  subject { self.klass.new(self.key) }

  let(:klass)         { Sodium::Auth::HMACSHA512256 }
  let(:key)           { Base64.decode64 'XMfWD8/yrcNDzJyGhxRIwi5tSGKf8D0ul9FyX/djvjg=' }
  let(:authenticator) { Base64.decode64 '6BN5+HNq0F8skQKkta+CLiBJ7mrrJaGw3G2J7jMT2qA=' }
  let(:plaintext)     { 'message' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal :hmacsha512256
  end

  it '::implementation must be itself' do
    self.klass.implementation.must_equal self.klass
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