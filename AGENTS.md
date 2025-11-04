# FjallRuby Agent Guide

## Build/Lint/Test Commands
- Build extension: `rake compile` or `bundle exec rake compile`
- Full build: `rake build`
- Install gem locally: `bundle exec rake install`
- Run console: `rake console` or `bin/console`
- Lint Ruby: `rubocop` (if installed)
- Lint/format Rust: `cargo fmt` and `cargo clippy`
- Test: Run `rake test` or `bundle exec rake test` (uses RSpec)
- Run specs: `rspec` or `rake spec`
- Single spec: `rspec path/to/spec_file.rb`

## Architecture
Ruby gem with Rust extension binding fjall (LSM-tree key-value database).
- `lib/`: Ruby code (entry point, partition aliases)
- `ext/fjall_ruby/`: Rust extension using Magnus for Ruby bindings
- Keyspace: top-level container (maps to fjall::Keyspace)
- Partition: named key-value store (maps to fjall::Partition)
- No external databases; this IS the database

## Code Style
- Ruby: frozen_string_literal, snake_case methods, CamelCase classes, standard Ruby conventions
- Rust: Standard Rust (edition 2021), snake_case functions, CamelCase structs, magnus macros for bindings
- Error handling: Rust errors map to FjallRuby::Error exceptions
- Imports: Ruby uses require_relative; Rust uses use statements
- Formatting: rubyfmt/rubocop for Ruby, cargo fmt for Rust
