require 'rake/testtask'

Rake::TestTask.new 'test' => 'sodium:compile' do |t|
  t.libs   << 'test'
  t.pattern = "test/**/*_test.rb"
end
