# frozen_string_literal: true

require 'fjall_ruby'
require 'tmpdir'

RSpec.describe FjallRuby::Partition do
  let(:temp_dir) { Dir.mktmpdir }
  let(:keyspace) { FjallRuby::Keyspace.new(temp_dir) }
  let(:partition_name) { 'test_partition' }
  let(:partition) { keyspace.open_partition(partition_name) }

  after do
    FileUtils.remove_entry(temp_dir) if Dir.exist?(temp_dir)
  end

  describe '#name' do
    it 'returns the partition name' do
      expect(partition.name).to eq(partition_name)
    end
  end

  describe '#insert' do
    it 'inserts a key-value pair' do
      expect { partition.insert('key1', 'value1') }.not_to raise_error
    end

    it 'overwrites existing key' do
      partition.insert('key1', 'value1')
      partition.insert('key1', 'value2')
      expect(partition.get('key1')).to eq('value2')
    end
  end

  describe '#get' do
    it 'returns the value for an existing key' do
      partition.insert('key1', 'value1')
      expect(partition.get('key1')).to eq('value1')
    end

    it 'returns nil for a non-existing key' do
      expect(partition.get('nonexistent')).to be_nil
    end
  end

  describe '#[]' do
    it 'is an alias for #get' do
      partition.insert('key1', 'value1')
      expect(partition['key1']).to eq('value1')
      expect(partition['nonexistent']).to be_nil
    end
  end

  describe '#[]=' do
    it 'is an alias for #insert' do
      partition['key1'] = 'value1'
      expect(partition.get('key1')).to eq('value1')
    end
  end

  describe '#remove' do
    it 'removes an existing key' do
      partition.insert('key1', 'value1')
      expect(partition.remove('key1')).to be_nil
      expect(partition.get('key1')).to be_nil
    end

    it 'does nothing for a non-existing key' do
      expect { partition.remove('nonexistent') }.not_to raise_error
      expect(partition.get('nonexistent')).to be_nil
    end
  end

  describe '#delete' do
    it 'is an alias for #remove' do
      partition.insert('key1', 'value1')
      partition.delete('key1')
      expect(partition.get('key1')).to be_nil
    end
  end

  describe '#contains_key' do
    it 'returns true for existing key' do
      partition.insert('key1', 'value1')
      expect(partition.contains_key('key1')).to be true
    end

    it 'returns false for non-existing key' do
      expect(partition.contains_key('nonexistent')).to be false
    end
  end

  describe '#key?' do
    it 'is an alias for #contains_key' do
      partition.insert('key1', 'value1')
      expect(partition.key?('key1')).to be true
      expect(partition.key?('nonexistent')).to be false
    end
  end

  describe '#each_key' do
    it 'iterates over all keys' do
      partition.insert('key1', 'value1')
      partition.insert('key2', 'value2')
      partition.insert('key3', 'value3')

      keys = []
      partition.each_key { |key| keys << key }
      expect(keys.sort).to eq(['key1', 'key2', 'key3'])
    end

    it 'returns empty array when no keys' do
      keys = []
      partition.each_key { |key| keys << key }
      expect(keys).to be_empty
    end
  end

  describe '#prefix' do
    before do
      partition.insert('prefix_key1', 'value1')
      partition.insert('prefix_key2', 'value2')
      partition.insert('other_key', 'value3')
      partition.insert('prefix_key3', 'value4')
    end

    it 'iterates over key-value pairs with matching prefix' do
      pairs = []
      partition.prefix('prefix_') { |key, value| pairs << [key, value] }
      expected = [
        ['prefix_key1', 'value1'],
        ['prefix_key2', 'value2'],
        ['prefix_key3', 'value4']
      ]
      expect(pairs.sort).to eq(expected.sort)
    end

    it 'returns empty when no matching prefix' do
      pairs = []
      partition.prefix('nonexistent_') { |key, value| pairs << [key, value] }
      expect(pairs).to be_empty
    end
  end

  describe 'persistence' do
    it 'persists data across partition instances' do
      partition.insert('persistent_key', 'persistent_value')
      keyspace.persist

      # Create new partition instance
      new_partition = keyspace.open_partition(partition_name)
      expect(new_partition.get('persistent_key')).to eq('persistent_value')
    end
  end

  describe 'error handling' do
    it 'handles special characters in keys and values' do
      special_key = "key\nwith\ttabs"
      special_value = "value\r\nwith\r\nlines"
      partition.insert(special_key, special_value)
      # Note: fjall escapes ASCII characters
      expect(partition.get(special_key)).to eq("value\\r\\nwith\\r\\nlines")
    end

    it 'handles unicode characters' do
      partition.insert('ключ', 'значение')
      # Note: fjall escapes non-ASCII characters
      expected = "\\xd0\\xb7\\xd0\\xbd\\xd0\\xb0\\xd1\\x87\\xd0\\xb5\\xd0\\xbd\\xd0\\xb8\\xd0\\xb5"
      expect(partition.get('ключ')).to eq(expected)
    end
  end
end
