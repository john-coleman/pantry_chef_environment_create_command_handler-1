source 'https://rubygems.org'

gem 'daemons'
gem 'aws-sdk'
gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', :tag => 'v0.1.6'
gem 'rest-client'
gem 'json'
gem 'chef','~> 11.6.0'
gem 'active_support'
gem 'i18n'

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :test, :development do
  gem 'em-winrm', git: 'https://github.com/besol/em-winrm.git'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec-fire'
  gem 'rspec'
  gem 'chef-zero'
  gem 'pry-debugger'
  gem 'rake'
end
