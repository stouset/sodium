require 'rake/testtask'

Rake::TestTask.new 'test' => 'libsodium:compile' do |t|
  t.libs   << 'test'
  t.pattern = 'test/**/*_test.rb'
end
