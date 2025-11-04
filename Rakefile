# frozen_string_literal: true

require "bundler/gem_tasks"
require "rb_sys/extensiontask"
require "rspec/core/rake_task"

task build: :compile

GEMSPEC = Gem::Specification.load("fjall_ruby.gemspec")

RbSys::ExtensionTask.new("fjall_ruby", GEMSPEC) do |ext|
  ext.lib_dir = "lib/fjall_ruby"
end

RSpec::Core::RakeTask.new(:spec)

task test: :spec

task default: [:compile, :spec]

desc "Open console with extension loaded"
task :console => :compile do
  exec "irb -r ./lib/fjall_ruby.rb"
end
