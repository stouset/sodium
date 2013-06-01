require 'coveralls'
require 'simplecov'

SimpleCov.adapters.define 'sodium' do
  add_filter '/test/'
  add_filter '/vendor/'
end

Coveralls.wear!('sodium')

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

require 'sodium'

require 'base64'

def sodium_override_default(klass, implementation)
  klass                = klass.dup
  klass.implementation = implementation
  yield klass
end

def sodium_mock_default(klass)
  mock = MiniTest::Mock.new
  sodium_override_default(klass, mock) {|dup| yield dup, mock }
  mock.verify
end

def sodium_stub_failure(klass, method, &block)
  klass.implementation.stub(method, false, &block)
end
