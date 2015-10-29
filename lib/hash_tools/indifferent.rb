require 'delegate'

# A tiny version of HashWithIndifferentAccess. Works like a wrapper proxy around a Ruby Hash.
# Does not support all of the methods for a Ruby Hash object, but nevertheless can be useful
# for checking params and for working with parsed JSON.
class HashTools::Indifferent < SimpleDelegator
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
  def [](k)
    v = __getobj__[__transform_key__(k)]
    __rewrap__(v)
  end
  
  # Set a value in the Hash, bu supplying a Symbol or a String as a key.
  # Key presence is verified by first trying a Symbol, and then a String.
  #
  # @param k the key to set
  # @param v the value to set
  # @return v
  def []=(k, v)
    __getobj__[ __transform_key__(k) ] = v
  end 
  
  # Fetch a value, by supplying a Symbol or a String as a key.
  # Key presence is verified by first trying a Symbol, and then a String.
  #
  # @param k the key to set
  # @param blk the block for no value
  # @return v
  def fetch(k, &blk)
    v = __getobj__.fetch( __transform_key__(k) , &blk)
    __rewrap__(v)
  end
  
  # Get the keys of the Hash. The keys are returned as-is (both Symbols and Strings).
  #
  # @return [Array] an array of keys
  def keys
    __getobj__.keys.map{|k| __transform_key__(k) }
  end
  
  # Checks for key presence whether the key is a String or a Symbol
  #
  # @param k[String,Symbol] the key to check
  def key?(k)
    __getobj__.has_key?( __transform_key__(k))
  end
  
  # Yields each key - value pair of the indifferent.
  # If the value is a Hash as well, that hash will be wrapped in an Indifferent before returning
  def each(&blk)
    __getobj__.each do |k, v|
      blk.call([__transform_key__(k), __rewrap__(v)])
    end
  end
  
  # Yields each key - value pair of the indifferent.
  # If the value is a Hash as well, that hash will be wrapped in an Indifferent before returning
  def each_pair
    o = __getobj__
    keys.each do | k |
      value = o[__transform_key__(k)]
      yield(k, __rewrap__(value))
    end
  end
  
  def map(&blk)
    keys.map do |k| 
      tk = __transform_key__(k)
      yield [tk, __rewrap__(__getobj__[tk])]
    end
  end
  
  def method_missing(method, *opts)
    m = method.to_s
    if self.key?(m)
      return self[m]
    elsif self.key?(m.to_sym)
      return self[m.to_sym]
    end
  end
  
  alias_method :has_key?, :key?
  
  private
  
  def __transform_key__(k)
    if __getobj__.has_key?(k.to_sym)
      k.to_sym
    else
      k.to_s
    end
  end 
  
  def __rewrap__(v)
    return v if v.is_a?(self.class)
    return self.class.new(v) if v.is_a?(Hash)
    return v.map{|e| __rewrap__(e)} if v.is_a?(Array)
    v
  end
end