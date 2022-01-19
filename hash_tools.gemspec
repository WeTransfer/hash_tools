# frozen_string_literal: true

require_relative "lib/hash_tools/version"

Gem::Specification.new do |spec|
  spec.name = "hash_tools"
  spec.version = HashTools::VERSION
  spec.authors = ["Julik Tarkhanov", "grdw"]
  spec.email = ["me@julik.nl", "gerard@wetransfer.com"]

  spec.summary = "Do useful things to Ruby Hashes"
  spec.description = "Do useful things to Ruby Hashes"
  spec.homepage = "https://github.com/WeTransfer/hash_tools"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
