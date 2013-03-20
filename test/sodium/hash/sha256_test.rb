require 'test_helper'

describe Sodium::Hash::SHA256 do
  let (:klass)     { Sodium::Hash::SHA256 }
  let (:primitive) { :sha256 }

  let :constants do
    { :BYTES => 32 }
  end

  let :hash do
    Base64.decode64 'q1MKE+RZFJgrefm34/uplM/R8/si9xzqGvvwK0YMbR0='
  end

  let(:plaintext) { 'message' }

  it '::primitive must be correct' do
    self.klass.primitive.must_equal self.primitive
  end

  it 'must have correct values for its constants' do
    self.constants.each_pair do |name, value|
      self.klass[name].must_equal value
    end
  end

  it 'must generate hashes' do
    self.klass.hash(
      self.plaintext
    ).must_equal self.hash
  end
end
