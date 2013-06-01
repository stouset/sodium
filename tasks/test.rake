require 'rake/testtask'


Rake::TestTask.new 'test' => 'sodium:compile' do |t|
  ENV['DYLD_LIBRARY_PATH'] = LIBSODIUM_LIBDIR
  ENV[  'LD_LIBRARY_PATH'] = LIBSODIUM_LIBDIR

  t.libs   << 'test'
  t.pattern = "test/**/*_test.rb"
end
