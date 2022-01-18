# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe HashTools do
  let(:t) do
    Class.new do
      include HashTools
    end.new
  end
  let(:uppercase) { ->(k) { k.upcase } }

  describe ".indifferent" do
    it "returns an indifferent wrapper" do
      h = { "foo" => { bar: 1 } }
      ind = t.indifferent(h)
      expect(ind[:foo][:bar]).to eq(1)
    end
  end

  it "transforms hash keys" do
    s = { "set" => 10 }
    ref = { "SET" => 10 }
    expect(t.transform_keys_of(s, &uppercase)).to eq(ref)
  end

  it "transforms nested hash keys" do
    s = { "set" => { "two" => 123 } }
    ref = { "SET" => { "TWO" => 123 } }
    expect(t.transform_keys_of(s, &uppercase)).to eq(ref)
  end

  it "does nothing to the array" do
    a = %w[a b c d]
    expect(t.transform_keys_of(a, &uppercase)).to eq(a)
  end

  it "transforms hashes embedded in arrays" do
    a = [{ "me" => "Julik" }]
    ref = [{ "ME" => "Julik" }]
    expect(t.transform_keys_of(a, &uppercase)).to eq(ref)
  end

  it "transforms nested hashes in an array" do
    a = { "foo" => [{ "me" => "Julik" }] }
    ref = { "FOO" => [{ "ME" => "Julik" }] }
    expect(t.transform_keys_of(a, &uppercase)).to eq(ref)
  end

  it "exposes methods on the module itself" do
    expect(HashTools).to respond_to(:transform_keys_of)
  end

  describe ".transform_string_values_of" do
    it "transforms the string value" do
      x = "foo"
      expect(t.transform_string_values_of(x, &uppercase)).to eq("FOO")
    end

    it "transforms strings in array" do
      x = %w[foo bar baz]
      ref = %w[FOO BAR BAZ]
      expect(t.transform_string_values_of(x, &uppercase)).to eq(ref)
    end

    it "transforms string values in a Hash" do
      x = { "foo" => "bar" }
      ref = { "foo" => "BAR" }
      expect(t.transform_string_values_of(x, &uppercase)).to eq(ref)
    end
  end

  describe ".transform_string_keys_and_values_of" do
    it "transforms both keys and values" do
      x = { "foo" => "bar" }
      ref = { "FOO" => "BAR" }
      expect(t.transform_string_keys_and_values_of(x, &uppercase)).to eq(ref)
    end
  end

  describe ".deep_fetch" do
    let(:deep) do
      {
        "foo" => 1,
        "bar" => {
          "baz" => 2
        },
        "array" => [1, 2, 3],
        "array-with-hashes" => [{ "name" => "Joe" }, { "name" => "Jane" }]
      }
    end

    it "accepts a block for a default value" do
      v = described_class.deep_fetch(deep, "bar/nonexistent") { :default }
      expect(v).to eq(:default)
    end

    it "fetches deep keys from a hash keyed by strings" do
      expect(described_class.deep_fetch(deep, "foo")).to eq(deep.fetch("foo"))
      expect(described_class.deep_fetch(deep, "bar/baz")).to eq(deep.fetch("bar").fetch("baz"))
    end

    it "fetches deep keys with a custom separator" do
      expect(described_class.deep_fetch(deep, "bar.baz", separator: ".")).to eq(deep.fetch("bar").fetch("baz"))
    end

    it "causes a KeyError to be raised for missing keys" do
      expect do
        described_class.deep_fetch(deep, "bar/nonexistent")
      end.to raise_error(KeyError, 'key not found: "nonexistent"')
    end

    it "allows fetches from arrays" do
      expect(described_class.deep_fetch(deep, "array/0")).to eq(1)
      expect(described_class.deep_fetch(deep, "array/-1")).to eq(3)
    end

    it "allows fetches from hashes within arrays" do
      expect(described_class.deep_fetch(deep, "array-with-hashes/0/name")).to eq("Joe")
      expect do
        described_class.deep_fetch(deep, "array-with-hashes/10/name")
      end.to raise_error(IndexError, /index 10 outside of array bounds/)

      default_value = described_class.deep_fetch(deep, "array-with-hashes/0/jake") { :default }
      expect(default_value).to eq(:default)
    end
  end

  describe ".deep_fetch_multi" do
    let(:deep) do
      {
        "foo" => 1,
        "bar" => {
          "baz" => 2
        },
        "array" => [1, 2, 3],
        "array-with-hashes" => [{ "name" => "Joe" }, { "name" => "Jane" }]
      }
    end

    it "fetches mutiple keys" do
      expect(described_class.deep_fetch_multi(deep, "foo", "bar/baz")).to eq([1, 2])
    end

    it "fetches deep keys with a custom separator" do
      expect(described_class.deep_fetch_multi(deep, "foo", "bar.baz", separator: ".")).to eq([1, 2])
    end

    it "causes a KeyError to be raised for missing keys" do
      expect do
        described_class.deep_fetch_multi(deep, "foo", "nonexistent")
      end.to raise_error(KeyError)
    end
  end

  describe ".deep_map_value" do
    it "deep maps the values" do
      v = [
        { "foo" => 5 },
        { "foo" => 6 }
      ]
      expect(described_class.deep_map_value(v, "foo")).to eq([5, 6])
    end

    it "deep maps the values with a custom separator" do
      v = [
        { "foo" => { "bar" => 1 } },
        { "foo" => { "bar" => 2 } }
      ]
      expect(described_class.deep_map_value(v, "foo-bar", separator: "-")).to eq([1, 2])
    end
  end
end
