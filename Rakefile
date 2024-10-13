# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "rake/extensiontask"

task build: :compile

Rake::ExtensionTask.new("odbc") do |ext|
  ext.lib_dir = "lib/odbc"
end

desc "Format C code"
task :clang_format do
  sh "clang-format -i ext/odbc/*.c"
end

task default: %i[clobber clang_format compile spec]
