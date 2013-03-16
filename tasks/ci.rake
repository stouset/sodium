require 'rake/clean'

task :'ci:sodium' => :'sodium:compile'
task :'ci'        => %w{ci:sodium test}
