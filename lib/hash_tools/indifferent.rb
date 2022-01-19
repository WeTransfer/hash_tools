# frozen_string_literal: true

require "delegate"

# A tiny version of HashWithIndifferentAccess. Works like a wrapper proxy around a Ruby Hash.
# Does not support all of the methods for a Ruby Hash object, but nevertheless can be useful
# for checking params and for working with parsed JSON.
module HashTools
  class Indifferent < SimpleDelegator
    # Create a new Indifferent by supplying a Ruby Hash object to wrap. The Hash being
    # wrapped is not going to be altered or copied.
    #
    # @param naked_hash [Hash] the Hash object to wrap with an Indifferent
    def initialize(naked_hash)
      __setobj__(naked_hash)
    end

    # Get a value from the Hash, bu supplying a Symbol or a String
    # Key presence is verified by first trying a Symbol, and then a String.
    #
    # @param k the key to fetch
    # @return the value, wrapped in {Indifferent} if it is a Hash
    def [](key)
      value = __getobj__[__transform_key__(key)]
      __rewrap__(value)
    end

    # Set a value in the Hash, bu supplying a Symbol or a String as a key.
    # Key presence is verified by first trying a Symbol, and then a String.
    #
    # @param k the key to set
    # @param v the value to set
    # @return v
    def []=(key, value)
      __getobj__[__transform_key__(key)] = value
    end

    # Fetch a value, by supplying a Symbol or a String as a key.
    # Key presence is verified by first trying a Symbol, and then a String.
    #
    # @param k the key to set
    # @param blk the block for no value
    # @return v
    def fetch(key, &blk)
      value = __getobj__.fetch(__transform_key__(key), &blk)
      __rewrap__(value)
    end

    # Get the keys of the Hash. The keys are returned as-is (both Symbols and Strings).
    #
    # @return [Array] an array of keys
    def keys
      __getobj__.keys.map { |key| __transform_key__(key) }
    end

    # Checks for key presence whether the key is a String or a Symbol
    #
    # @param k[String,Symbol] the key to check
    def key?(key)
      __getobj__.key?(__transform_key__(key))
    end

    # Checks if the value at the given key is non-empty
    #
    # @param k[String,Symbol] the key to check
    def value_present?(key)
      return false unless key?(key)

      value = self[key]
      return false unless value

      !value.to_s.empty?
    end

    # Yields each key - value pair of the indifferent.
    # If the value is a Hash as well, that hash will be wrapped in an Indifferent before returning
    def each(&blk)
      __getobj__.each do |key, value|
        blk.call([__transform_key__(key), __rewrap__(value)])
      end
    end

    # Yields each key - value pair of the indifferent.
    # If the value is a Hash as well, that hash will be wrapped in an Indifferent before returning
    def each_pair
      object = __getobj__
      keys.each do |key|
        value = object[__transform_key__(key)]
        yield(key, __rewrap__(value))
      end
    end

    # Maps over keys and values of the Hash. The key class will be preserved (i.e. within
    # the block the keys will be either Strings or Symbols depending on what is used in the
    # underlying Hash).
    def map
      keys.map do |key|
        transform_key = __transform_key__(key)
        yield [transform_key, __rewrap__(__getobj__[transform_key])]
      end
    end

    # There is a quirk whereby the delegate library will not pass `to_json` to the
    # contained Hash, and the Indifferent would the JSON-serialize as a String.
    # We have to forward this method explicitly.
    #
    # In general, the method will never be called by the user directly but will instead
    # be excercised by `JSON.dump()` and friends.
    def to_json(*serializer_state)
      to_h.to_json(*serializer_state)
    end

    def method_missing(method_name, *args)
      return self[method_name] if key?(method_name) && args.empty?

      super
    end

    def respond_to_missing?(method_name, _include_private = false)
      key?(method_name)
    end

    def to_hash
      __getobj__.to_hash
    end

    alias has_key? key?

    private

    def __transform_key__(key)
      if __getobj__.key?(key.to_sym)
        key.to_sym
      else
        key.to_s
      end
    end

    def __rewrap__(value)
      return value if value.is_a?(self.class)
      return self.class.new(value) if value.is_a?(Hash)
      return value.map { |e| __rewrap__(e) } if value.is_a?(Array)

      value
    end
  end
end
