require 'test_helper'

describe Sodium::OneTimeAuth::Poly1305 do
  subject { self.klass.new(self.key) }

  let(:klass)     { Sodium::OneTimeAuth::Poly1305 }
  let(:primitive) { :poly1305 }

  let :constants do
    { :BYTES    => 16,
      :KEYBYTES => 32, }
  end

  let(:key)           { Base64.decode64 'tZUeTVtSHOfgOei4DUwCt10xqrIYhALpO08NIDMWFB0=' }
  let(:authenticator) { Base64.decode64 'n+6StqC6SLRuLT8YZoQoFw==' }
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
    self.klass.key.length.
      must_equal self.klass::KEYBYTES
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
      self.authenticator.suck
    ).must_equal false
  end
end
