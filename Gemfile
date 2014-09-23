source 'https://rubygems.org'

gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', tag: 'v0.2.6'
gem 'chef', '~> 11.12'
gem 'activesupport', '~> 4.0'

group :development do
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :test, :development do
  gem 'chef-zero'
  gem 'pry'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end
