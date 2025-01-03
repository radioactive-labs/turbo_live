# frozen_string_literal: true

require_relative "lib/turbo_live/version"

Gem::Specification.new do |spec|
  spec.name = "turbo_live"
  spec.version = TurboLive::VERSION
  spec.authors = ["TheDumbTechGuy"]
  spec.email = ["sfroelich01@gmail.com"]

  spec.summary = "Async, progressively enhanced, live components for Ruby applications"
  spec.description = "Async, progressively enhanced, live components for Ruby applications that work over Websockets and HTTP."
  spec.homepage = "https://github.com/radioactive-labs/turbo_live"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/radioactive-labs/turbo_live"
  spec.metadata["changelog_uri"] = "https://github.com/radioactive-labs/turbo_live/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "phlex-rails"
  spec.add_dependency "literal"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
