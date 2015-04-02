require File.expand_path("#{File.dirname(__FILE__)}/lib/task/dev.rb")
require File.expand_path("#{File.dirname(__FILE__)}/lib/dokr.rb")
require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks
ActiveRecord::Base.schema_format = :sql

Dir.glob("#{PROJ_DIR}/lib/task/*.rake"){|p| import p}

desc "start dev.: dir=[web|data]"
task :cc, [:dir] do |t,arg|
  sh "rake clean"
  exec "rake dev:start[#{arg.dir}]"
end

desc "compile/link code"
task :c, [:dir] => 'dev:make'

desc "test code"
task :t => :test

task :spec => 'dev:spec'
task :test => 'dev:test'
task :clean => 'dev:clean'
task :build => 'dev:build'
task :install => 'dev:install'
task :update => 'dev:update'
task :clean => 'dev:clean'

task :ghci, [:dir] => 'dev:ghci'

task :default do; sh "rake -T", verbose: false; end
