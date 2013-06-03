require 'test_helper'

describe Sodium::Random do
  subject { Sodium::Random }

  it '::bytes must generate a byte string of desired length' do
    subject.bytes( 30).bytesize.must_equal  30
    subject.bytes(400).bytesize.must_equal 400
  end

  it '::bytes must generate random bytes' do
    1_000.times.map { subject.bytes(16) }.uniq.length.
      must_equal 1_000
  end

  it '::integer must generate a single random number' do
    1_000.times.map { subject.integer }.uniq.length.
      must_equal 1_000
  end

  it 'must generate random numbers up to a given max' do
    1_000.times.map { subject.integer(4) }.any? {|n| n >= 4 }.
      must_equal false
  end
end
