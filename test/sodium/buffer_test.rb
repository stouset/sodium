require 'test_helper'

describe Sodium::Buffer do
  subject { Sodium::Buffer }

  it '::key must securely generate random keys of specified length' do
    Sodium::Random.stub(:bytes, lambda {|l| ' ' * l }) do
      subject.key( 7).to_str.must_equal(' ' *  7)
      subject.key( 8).to_str.must_equal(' ' *  8)
      subject.key(16).to_str.must_equal(' ' * 16)
      subject.key(32).to_str.must_equal(' ' * 32)
      subject.key(64).to_str.must_equal(' ' * 64)
    end
  end

  it '::nonce must securely generate random nonces of specified length' do
    Sodium::Random.stub(:bytes, lambda {|l| ' ' * l }) do
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

  it '::empty must yield to a block when given' do
    mock = MiniTest::Mock.new
    mock.expect :flag, nil

    subject.empty(5) {|buffer| mock.flag }

    mock.verify
  end

  it '::ljust must pad zero bytes on the end' do
    subject.ljust('xyz', 5).to_str.must_equal "xyz\0\0"
  end

  it '::ljust must not pad bytes when not needed' do
    subject.ljust('xyz', 2).to_str.must_equal 'xyz'
  end

  it '::rjust must pad zero bytes onto the front' do
    subject.rjust('xyz', 5).to_str.must_equal "\0\0xyz"
  end

  it '::rjust must not pad bytes when not needed' do
    subject.rjust('xyz', 2).to_str.must_equal 'xyz'
  end

  it '::lpad must prepend the required number of bytes' do
    subject.lpad('xyz', 0).to_str.must_equal 'xyz'
    subject.lpad('xyz', 2).to_str.must_equal "\0\0xyz"
  end

  it '::rpad must append the required number of bytes' do
    subject.rpad('xyz', 0).to_str.must_equal 'xyz'
    subject.rpad('xyz', 2).to_str.must_equal "xyz\0\0"
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

  it '#[]= must allow replacement of byte ranges' do
    subject.new('xyz').tap {|b| b[0, 3] = 'abc' }.to_str.must_equal 'abc'
    subject.new('xyz').tap {|b| b[0, 2] = 'ab'  }.to_str.must_equal 'abz'
    subject.new('xyz').tap {|b| b[2, 1] = 'c'   }.to_str.must_equal 'xyc'
  end

  it '#[]= must not allow resizing the buffer' do
    lambda { subject.new('xyz')[0, 1] = 'ab' }.must_raise ArgumentError
    lambda { subject.new('xyz')[0, 2] = 'a'  }.must_raise ArgumentError
    lambda { subject.new('xyz')[3, 1] = 'a'  }.must_raise ArgumentError
    lambda { subject.new('xyz')[2, 2] = 'ab' }.must_raise ArgumentError
  end

  it '#[] must accept an indivdual byte offset to return' do
    subject.new('xyz').tap do |buffer|
      buffer[-4].to_str.must_equal ''
      buffer[-3].to_str.must_equal 'x'
      buffer[-2].to_str.must_equal 'y'
      buffer[-1].to_str.must_equal 'z'
      buffer[ 0].to_str.must_equal 'x'
      buffer[ 1].to_str.must_equal 'y'
      buffer[ 2].to_str.must_equal 'z'
      buffer[ 3].to_str.must_equal ''
    end
  end

  it '#[] must accept ranges of bytes to return' do
    subject.new('xyz').tap do |buffer|
      buffer[ 0.. 0].to_str.must_equal 'x'
      buffer[ 0.. 1].to_str.must_equal 'xy'
      buffer[ 0.. 2].to_str.must_equal 'xyz'
      buffer[ 0.. 3].to_str.must_equal 'xyz'
      buffer[ 1..-1].to_str.must_equal 'yz'
      buffer[ 2..-2].to_str.must_equal ''
      buffer[-3..-1].to_str.must_equal 'xyz'
      buffer[-4.. 1].to_str.must_equal ''
    end
  end

  it '#[] must accept an offset and number of bytes to return' do
    subject.new('xyz').tap do |buffer|
      buffer[ 0,  0].to_str.must_equal ''
      buffer[ 0,  1].to_str.must_equal 'x'
      buffer[ 0,  3].to_str.must_equal 'xyz'
      buffer[ 2,  4].to_str.must_equal 'z'
      buffer[ 2,  1].to_str.must_equal 'z'
      buffer[-2,  1].to_str.must_equal 'y'
      buffer[ 0, -1].to_str.must_equal ''
    end
  end

  it '#[] must return its length' do
    subject.new('testing').bytesize.must_equal 7
  end

  it '#inspect must not reveal its instance variables' do
    subject.new('blah').inspect.wont_include 'blah'
  end

  it '#to_str must return its internal bytes' do
    subject.new('xyz').to_str.must_equal('xyz')
  end
end
