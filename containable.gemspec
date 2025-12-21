# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "containable"
  spec.version = "1.5.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/containable"
  spec.summary = "A thread-safe dependency injection container."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/containable/issues",
    "changelog_uri" => "https://alchemists.io/projects/containable/versions",
    "homepage_uri" => "https://alchemists.io/projects/containable",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Containable",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/containable"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 4.0"
  spec.add_dependency "concurrent-ruby", "~> 1.3"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
