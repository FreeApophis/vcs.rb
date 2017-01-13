require "rake/testtask"

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = Dir["test/*.rb"]
end
desc "Run tests for vcs_ruby"
