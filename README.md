# FjallRuby

FjallRuby provides Ruby bindings for [fjall](https://github.com/fjall-rs/fjall), an LSM-based embedded key-value storage engine. It offers a simple, persistent key-value store without requiring an external database server.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

### Basic Usage

```ruby
require "fjall_ruby"

# Create or open a keyspace (database)
keyspace = FjallRuby::Keyspace.new("/path/to/data")

# Open a partition (like a table or collection)
partition = keyspace.open_partition("my_partition")

# Insert key-value pairs
partition.insert("user:1", "Alice")
partition.insert("user:2", "Bob")

# Retrieve values
partition.get("user:1")  #=> "Alice"
partition.get("user:99") #=> nil

# Check if a key exists
partition.contains_key("user:1") #=> true
partition.key?("user:99")        #=> false

# Remove keys
partition.remove("user:2")
partition.get("user:2") #=> nil

# Persist changes to disk
keyspace.persist
```

### Hash-like Interface

Partitions support Ruby's hash-like syntax for convenience:

```ruby
partition["user:3"] = "Charlie"  # Same as partition.insert("user:3", "Charlie")
partition["user:3"]              # Same as partition.get("user:3")
partition.delete("user:3")       # Same as partition.remove("user:3")
```

### Iteration

Iterate over all keys in a partition:

```ruby
partition.insert("apple", "red")
partition.insert("banana", "yellow")
partition.insert("cherry", "red")

partition.each_key do |key|
  puts "#{key}: #{partition[key]}"
end
# Output:
# apple: red
# banana: yellow
# cherry: red
```

### Prefix Scanning

Efficiently query keys with a common prefix:

```ruby
partition.insert("user:1:name", "Alice")
partition.insert("user:1:email", "alice@example.com")
partition.insert("user:2:name", "Bob")

partition.prefix("user:1:") do |key, value|
  puts "#{key} = #{value}"
end
# Output:
# user:1:name = Alice
# user:1:email = alice@example.com
```

### Multiple Partitions

A single keyspace can contain multiple partitions:

```ruby
keyspace = FjallRuby::Keyspace.new("/path/to/data")

users = keyspace.open_partition("users")
posts = keyspace.open_partition("posts")
comments = keyspace.open_partition("comments")

users["u1"] = "Alice"
posts["p1"] = "Hello World"
comments["c1"] = "Great post!"

# All partitions share the same keyspace and persistence
keyspace.persist
```

### Partition Names

You can retrieve the name of a partition:

```ruby
partition = keyspace.open_partition("my_data")
partition.name #=> "my_data"
```

### Error Handling

FjallRuby operations raise `FjallRuby::Error` exceptions on failure:

```ruby
begin
  keyspace = FjallRuby::Keyspace.new("/invalid/path")
  partition = keyspace.open_partition("data")
  partition.insert("key", "value")
rescue FjallRuby::Error => e
  puts "Database error: #{e.message}"
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fjall_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/fjall_ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FjallRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fjall_ruby/blob/main/CODE_OF_CONDUCT.md).
