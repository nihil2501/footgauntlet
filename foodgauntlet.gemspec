# frozen_string_literal: true

require_relative "lib/footgauntlet/version"

Gem::Specification.new do |spec|
  spec.name = "footgauntlet"
  spec.version = Footgauntlet::VERSION
  spec.authors = ["Oren Mittman"]
  spec.email = ["nihil2501@gmail.com"]

  spec.summary = "Many enter, but only one leaves."
  spec.homepage = "https://github.com/nihil2501/footgauntlet"
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["allowed_push_host"] = "https://push.fury.io/nihil2501/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ .git])
    end
  end

  spec.bindir = "bin"
  spec.executables = ["footgauntlet"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~>5.18"
  spec.add_development_dependency "rake", "~>13.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
