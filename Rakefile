require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.pattern = "test/*_test.rb"
end
