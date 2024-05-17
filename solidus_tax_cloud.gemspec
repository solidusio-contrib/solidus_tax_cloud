# frozen_string_literal: true

require_relative 'lib/solidus_tax_cloud/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_tax_cloud'
  spec.version = SolidusTaxCloud::VERSION
  spec.authors = ['Jerrold Thompson']
  spec.email = 'jet@whidbey.com'

  spec.summary = 'Solidus extension providing Tax Cloud services'
  spec.description = 'Solidus extension providing Tax Cloud services'
  spec.homepage = 'https://github.com/solidusio-contrib/solidus_tax_cloud'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio-contrib/solidus_tax_cloud'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio-contrib/solidus_tax_cloud/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'deface'
  spec.add_dependency 'savon', '~> 2.12.0'
  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 4']
  spec.add_dependency 'solidus_support', '~> 0.5'
  spec.add_dependency 'tax_cloud', '~> 0.6.0'

  spec.add_development_dependency 'solidus_dev_support'
end
