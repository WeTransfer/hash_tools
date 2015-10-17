# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: hash_tools 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hash_tools"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Julik Tarkhanov"]
  s.date = "2015-10-17"
  s.description = "Do useful things to Ruby Hashes"
  s.email = "me@julik.nl"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".yardopts",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "hash_tools.gemspec",
    "lib/hash_tools.rb",
    "lib/hash_tools/indifferent.rb",
    "spec/hash_tools/indifferent_spec.rb",
    "spec/hash_tools_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/julik/hash_tools"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Do useful things to Ruby Hashes"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["< 3.3", "~> 3.2.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
    else
      s.add_dependency(%q<rspec>, ["< 3.3", "~> 3.2.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    end
  else
    s.add_dependency(%q<rspec>, ["< 3.3", "~> 3.2.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
  end
end

