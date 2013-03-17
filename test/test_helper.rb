require 'coveralls'
require 'simplecov'

SimpleCov.adapters.define 'sodium' do
  add_filter '/test/'
  add_filter '/vendor/'
end

Coveralls.wear!('sodium')

require 'minitest/spec'
require 'minitest/pride'
require 'minitest/hell'
require 'minitest/autorun'

require 'sodium'

require 'base64'

def sodium_override_default(klass, implementation)
  klass                = klass.dup
  klass.implementation = implementation
  yield klass
end

def sodium_mock_default(klass)
  mock = MiniTest::Mock.new
  sodium_override_default(klass, mock) {|klass| yield klass, mock }
  mock.verify
end

def sodium_stub_failure(klass, method, &block)
  klass.implementation.stub(method, false, &block)
end
