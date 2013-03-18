require 'test_helper'

class DelegateTest
  include Sodium::Delegate

  def self.[](key)
    self.const_get(key)
  end

  class Subclass1 < self; PRIMITIVE = :subclass1; end
  class Subclass2 < self; PRIMITIVE = :subclass2; end

  DEFAULT = :subclass1
end

describe Sodium::Delegate do
  subject        { self.klass.new          }
  let(:klass)    { DelegateTest            }
  let(:subclass) { DelegateTest::Subclass1 }

  it '::implementation must be the default' do
    self.klass.implementation.must_equal self.subclass
  end

  it 'must allow access to constants through indexing' do
    self.klass.implementation[:PRIMITIVE].must_equal :subclass1
  end

  it 'must allow access to arbitrary implementations' do
    self.klass.implementation(:subclass2).must_equal DelegateTest::Subclass2
  end

  it 'must instantiate the default implementation' do
    self.klass.new.class.must_equal self.subclass
  end

  it 'must allow instance access to the instantiated primitive' do
    self.subject.primitive.must_equal self.subclass::PRIMITIVE
  end

  it 'must allow class access to the instantiated primitive' do
    self.subject.class.primitive.must_equal self.subclass::PRIMITIVE
  end
end
