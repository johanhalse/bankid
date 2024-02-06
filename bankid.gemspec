# frozen_string_literal: true

require_relative "lib/bankid/version"

Gem::Specification.new do |spec|
  spec.name        = "bankid"
  spec.version     = Bankid::VERSION
  spec.authors     = ["Johan Halse"]
  spec.email       = ["johan@hal.se"]
  spec.summary     = "BankID authentication for Ruby."
  spec.description = "A simple and easy way to add Swedish BankID QR code login to your site."
  spec.homepage    = "https://github.com/johanhalse/bankid"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/johanhalse/bankid"
  spec.metadata["changelog_uri"] = "https://github.com/johanhalse/bankid/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "http", "~> 5.1.1"
  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "rqrcode", "~> 2.2.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
