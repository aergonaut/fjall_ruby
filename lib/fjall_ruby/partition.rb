# frozen_string_literal: true

module FjallRuby
  class Partition
    alias_method :[], :get
    alias_method :[]=, :insert
    alias_method :delete, :remove
    alias_method :key?, :contains_key
  end
end
