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
