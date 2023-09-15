# frozen_string_literal: true

require_relative "lib/bankid/version"

Gem::Specification.new do |spec|
  spec.name          = "bankid"
  spec.version       = Bankid::VERSION
  spec.authors       = ["Johan Halse"]
  spec.email         = ["johan@hal.se"]

  spec.summary       = "BankID authentication for Ruby."
  spec.description   = "A simple and easy way to add Swedish BankID QR code login to your site."
  spec.homepage      = "https://github.com/johanhalse/bankid"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/johanhalse/bankid"
  spec.metadata["changelog_uri"] = "https://github.com/johanhalse/bankid/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "http", "~> 5.1.1"
  spec.add_dependency "rqrcode", "~> 2.2.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
