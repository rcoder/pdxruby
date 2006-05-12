# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/switchtower.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

task :default => [ :test_units, :test_functional ]

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
