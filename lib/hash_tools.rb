module HashTools
  VERSION = '1.2.3'
  
  require_relative 'hash_tools/indifferent'
  
  FWD_SLASH = '/' # Used as the default separator for deep_fetch
  INT_KEY_RE = /^\-?\d+$/ # Regular expression to detect array indices in the path ("phones/0/code")
  
  # Fetch a deeply-nested hash key from a hash, using a String representing a path
  #
  #     deep_fetch({
  #       'a' => {
  #         'b' => {
  #           'c' => value}}
  #     }, 'a/b/c') #=> value
  #
  # @param hash [Hash] the (potentially deep) string-keyed Hash to fetch the value from
  # @param path [String] the path to the item in `hash`. The path may contain numbers for deeply nested arrays ('foo/0/bar')
  # @param separator [String] the path separator, defaults to '/'
  # @param default_blk The default value block for when there is no value.
  # @return the fetched value or the value of the default_block
  def deep_fetch(hash, path, separator: FWD_SLASH, &default_blk)
    keys = path.split(separator)
    keys.inject(hash) do |hash_or_array, k|
      if !hash_or_array.respond_to?(:fetch)
        raise "#{hash_or_array.inspect} does not respond to #fetch"
      elsif hash_or_array.is_a?(Array) && k =~ INT_KEY_RE
        hash_or_array.fetch(k.to_i, &default_blk)
      else
        hash_or_array.fetch(k, &default_blk)
      end
    end
  end
  
  # Fetches multiple keys from a deep hash, using a Strings representing paths
  #
  #     deep_fetch({
  #       'z' => 1,
  #       'a' => {
  #         'b' => {
  #           'c' => value}}
  #     }, 'a/b', 'z') #=> [value, 1]
  #
  # @param hash [Hash] the (potentially deep) string-keyed Hash to fetch the value from
  # @param key_paths [String] the paths to the items in `hash`. The paths may contain numbers for deeply nested arrays ('foo/0/bar')
  # @param separator [String] the path separator, defaults to '/'
  # @return [Array] the fetched values
  def deep_fetch_multi(hash, *key_paths, separator: FWD_SLASH)
    key_paths.map{|k| deep_fetch(hash, k, separator: separator) }
  end
  
  # Fetches a deeply nested key from each of the Hashes in a given Array.
  #
  #     arr = [
  #       {'age' => 12, 'name' => 'Jack'},
  #       {'age' => 25, 'name' => 'Joe'},
  #     ]
  #     deep_map_value(arr, 'age') => [12, 25]
  #
  # @param enum_of_hashes [Enumerable] a list of Hash objects to fetch the values from
  # @param path [String] the paths to the value. Paths may contain numbers for deeply nested arrays ('foo/0/bar')
  # @param separator [String] the path separator, defaults to '/'
  # @return [Array] the fetched values
  def deep_map_value(enum_of_hashes, path, separator: FWD_SLASH)
    enum_of_hashes.map{|h| deep_fetch(h, path, separator: separator)}
  end
  
  # Recursively transform string keys and values of a passed
  # Hash or Array using the passed transformer
  #
  # @param any [Hash,String,Array] the value to transform the contained items in
  # @param transformer The block applied to each string key and value, recursively
  # @return the transformed value
  def transform_string_keys_and_values_of(any, &transformer)
    transform_string_values_of(transform_keys_of(any, &transformer), &transformer)
  end
  
  # Recursively convert string values in nested hashes and
  # arrays using a passed block. The block will receive the String
  # to transform and should return a transformed string.
  #
  # @param any [Hash,String,Array] the value to transform the contained items in
  # @param transformer The block applied to each string value, recursively
  # @return the transformed value
  def transform_string_values_of(any, &transformer)
    if any.is_a?(String)
      transformer.call(any)
    elsif any.is_a?(Array)
      any.map{|e| transform_string_values_of(e, &transformer) }
    elsif any.is_a?(Hash)
      h = {}
      any.each_pair do |k, v|
        h[k] = transform_string_values_of(v, &transformer)
      end
      h
    else
      any
    end
  end
  
  # Recursively convert hash keys using a block.
  # using a passed block. The block will receive a hash key
  # to be transformed and should return a transformed key
  # For example, to go from uderscored notation to camelized:
  #
  #      h = {'foo_bar' => 1}
  #      transform_keys_of(h) {|k| k.to_s.camelize(:lower) } # => {'fooBar' => 1}
  #
  # @param any [Hash] the Hash to transform
  # @param transformer the block to apply to each key, recursively
  # @return [Hash] the transformed Hash
  def transform_keys_of(any, &transformer)
    if any.is_a?(Array)
      return any.map{|e| transform_keys_of(e, &transformer) }
    elsif any.is_a?(Hash)
      h = {}
      any.each_pair do |k, v|
        h[transformer.call(k.to_s)] = transform_keys_of(v, &transformer)
      end
      h
    else
      any
    end
  end
  
  # Returns an {HashTools::Indifferent} wrapper for the given Hash.
  #
  # @param hash [Hash] the Hash to wrap
  # @return [Indifferent] the wrapper for the hash
  def indifferent(hash)
    Indifferent.new(hash)
  end
  
  extend self
end
