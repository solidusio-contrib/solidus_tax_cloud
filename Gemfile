source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

group :test do
  if branch == 'master' || branch >= "v2.0"
    gem "rails-controller-testing"
  else
    gem "rails_test_params_backport"
  end
end

gem 'rake', '< 11.0'
gem 'capybara-screenshot', group: :test

gem 'pg'
gem 'mysql2'

gemspec
