require 'test_helper'

describe Sodium::Hash::SHA512 do
  include SodiumTestHelpers

  let (:klass)     { Sodium::Hash::SHA512 }
  let (:primitive) { :sha512 }

  let :constants do
    { :BYTES => 64 }
  end

  let_64(:hash) do
    %{ +Nr1ejNHzE1rnVdbMf5gd+LLSH9gqWIzwIy0edvzFTjMkV7G1IvbqpbdwaFt
       tPT5bzcnbPyzUQuCRiQXcNWVLA== }
  end

  let_64(:plaintext) { 'bWVzc2FnZQ==' }

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
    ).to_s.must_equal self.hash
  end
end
