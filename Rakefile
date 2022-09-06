require 'rspec/core/rake_task'
require 'pathname'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts=["--format","doc"]
end

task :default => :spec

run_main=proc do |task|
  base=Pathname.new("./#{task.name}/")
  ARGV.replace(FileList[base / "*.stone"])
  main=base / "main.rb"
  puts "running #{main}"
  load main
end

task :ch3, &run_main
