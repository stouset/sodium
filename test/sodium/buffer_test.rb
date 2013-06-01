require 'test_helper'

describe Sodium::Buffer do
  subject { Sodium::Buffer }

  it '::key must securely generate random keys of specified length' do
    SecureRandom.stub(:random_bytes, lambda {|l| ' ' * l }) do
      subject.key( 7).to_str.must_equal(' ' *  7)
      subject.key( 8).to_str.must_equal(' ' *  8)
      subject.key(16).to_str.must_equal(' ' * 16)
      subject.key(32).to_str.must_equal(' ' * 32)
      subject.key(64).to_str.must_equal(' ' * 64)
    end
  end

  it '::nonce must securely generate random nonces of specified length' do
    SecureRandom.stub(:random_bytes, lambda {|l| ' ' * l }) do
      subject.nonce( 7).to_str.must_equal(' ' *  7)
      subject.nonce( 8).to_str.must_equal(' ' *  8)
      subject.nonce(16).to_str.must_equal(' ' * 16)
      subject.nonce(32).to_str.must_equal(' ' * 32)
      subject.nonce(64).to_str.must_equal(' ' * 64)
    end
  end

  it '::empty must generate an empty buffer of specified length' do
    subject.empty(32).to_str.must_equal("\0" * 32)
    subject.empty(40).to_str.must_equal("\0" * 40)
  end

  it '::new must create a buffer containing the specified string' do
    subject.new('xyz'     ).to_str.must_equal('xyz')
    subject.new('xyz' * 50).to_str.must_equal('xyz' * 50)
  end

  it '::new must do optional length checking' do
    lambda { subject.new('xyz', 4).to_str }.
      must_raise Sodium::LengthError
  end

  it '#initialize must freeze its bytes' do
    subject.new('s').to_str.must_be :frozen?
  end

  it '#initialize must wipe the memory from the original string' do
    'test'.tap do |s|
      subject.new(s)
    end.must_equal("\0" * 4)
  end

  it '#initialize must wipe the buffer during finalization'
  it '#initialize must prevent the string from being paged to disk'

  it '#pad bytes onto the front' do
    subject.new('s').pad(3).to_str.must_equal "\0\0\0s"
  end

  it '#unpad bytes from the front' do
    subject.new("\0\0\0s").unpad(3).to_str.must_equal 's'
  end

  it '#bytesize must return its length' do
    subject.new('testing').bytesize.must_equal 7
  end

  it '#inspect must not reveal its instance variables' do
    subject.new('blah').inspect.wont_include 'blah'
  end

  it '#to_str must return its internal bytes' do
    subject.new('xyz').to_str.must_equal('xyz')
  end
end
