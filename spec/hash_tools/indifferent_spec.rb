# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe HashTools::Indifferent do
  it "supports indifferent access" do
    h_syms = { a: 1, "b" => 2 }
    wrapper = described_class.new(h_syms)

    expect(wrapper["a"]).to eq(1)
    expect(wrapper[:a]).to eq(1)
    expect(wrapper.fetch("a")).to eq(1)
    expect(wrapper.fetch(:a)).to eq(1)

    expect(wrapper["b"]).to eq(2)
    expect(wrapper[:b]).to eq(2)
    expect(wrapper.fetch("b")).to eq(2)
    expect(wrapper.fetch(:b)).to eq(2)

    expect(wrapper.a).to eq(1)
    expect(wrapper.b).to eq(2)

    expect(wrapper.keys).to eq(h_syms.keys)
  end

  it "serializes as a JSON object when used as an array member" do
    require "json"
    h = { a: 1 }
    i = described_class.new(h)
    array = [h, i]
    dumped = JSON.dump(array)
    loaded = JSON.parse(dumped)
    expect(loaded[1]).to eq(loaded[0]) # The object representations should be equivalent
  end

  it "raises NoMethodError when accessing missing keys via dot notation" do
    h_syms = { a: 1, "b" => 2 }
    wrapper = described_class.new(h_syms)

    expect do
      wrapper.c
    end.to raise_error(NoMethodError)
  end

  it "supports indifferent access to deeply nested hashes" do
    h_deep = { a: { :b => 1, "c" => 2 } }

    wrapper = described_class.new(h_deep)
    expect(wrapper[:a][:b]).to eq(1)
    expect(wrapper["a"]["b"]).to eq(1)

    expect(wrapper[:a][:c]).to eq(2)
    expect(wrapper["a"]["c"]).to eq(2)

    expect(wrapper.a.b).to eq(1)
    expect(wrapper.a.c).to eq(2)

    expect(wrapper.keys).to eq(h_deep.keys)
  end

  it "supports has_non_empty?" do
    h_deep = { a: 1, b: "", c: false, d: nil }
    wrapper = described_class.new(h_deep)

    expect(wrapper).to be_value_present(:a)

    expect(wrapper).not_to be_value_present(:z)
    expect(wrapper).not_to be_value_present("z")

    expect(wrapper).not_to be_value_present(:b)
    expect(wrapper).not_to be_value_present(:c)
    expect(wrapper).not_to be_value_present(:d)
  end

  it "supports being an argument to Hash#merge!" do
    h_deep = { a: 1, b: "", c: false, d: nil }
    wrapper = described_class.new(h_deep)

    target = { "foo" => true }
    target.merge!(wrapper)
  end

  it "supports map" do
    h_deep = { :a => { b: 1 }, "b" => { "b" => 2 } }
    wrapper = described_class.new(h_deep)

    wrapper.map do |(_k, v)|
      expect(v["b"]).not_to be_nil
      expect(v[:b]).not_to be_nil
    end
  end

  it "supports indifferent access to inner arrays" do
    h_deep = { a: [{ b: 1 }] }
    wrapper = described_class.new(h_deep)

    expect(wrapper[:a][0][:b]).to eq(1)
    expect(wrapper["a"][0]["b"]).to eq(1)
  end
end
