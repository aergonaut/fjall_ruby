# frozen_string_literal: true

require "bundler/gem_tasks"
require "rb_sys/extensiontask"
require "rspec/core/rake_task"

task build: :compile

GEMSPEC = Gem::Specification.load("fjall_ruby.gemspec")

RbSys::ExtensionTask.new("fjall_ruby", GEMSPEC) do |ext|
  ext.lib_dir = "lib/fjall_ruby"

  ext.cross_compile = true
  ext.cross_platform = [
    "x86_64-linux",
    "aarch64-linux",
    "x86_64-darwin",
    "arm64-darwin",
    "x64-mingw-ucrt"
  ]
end

RSpec::Core::RakeTask.new(:spec)

task test: :spec

task default: [:compile, :spec]

desc "Open console with extension loaded"
task console: :compile do
  exec "irb -r ./lib/fjall_ruby.rb"
end
