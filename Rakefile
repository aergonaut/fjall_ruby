# frozen_string_literal: true

require "bundler/gem_tasks"
require "rb_sys/extensiontask"

task build: :compile

GEMSPEC = Gem::Specification.load("fjall_ruby.gemspec")

RbSys::ExtensionTask.new("fjall_ruby", GEMSPEC) do |ext|
  ext.lib_dir = "lib/fjall_ruby"
end

task default: :compile

desc "Open console with extension loaded"
task :console => :compile do
  exec "irb -r ./lib/fjall_ruby.rb"
end
