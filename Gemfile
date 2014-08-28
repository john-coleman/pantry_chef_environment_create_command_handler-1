source 'https://rubygems.org'

gem 'pantry_daemon_common', git: 'git@github.com:wongatech/pantry_daemon_common.git', :tag => 'v0.2.6'
gem 'chef','~> 11.12'
gem 'activesupport', '~> 4.0'

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :test, :development do
  gem 'em-winrm', git: 'https://github.com/besol/em-winrm.git'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec', '>= 3.0'
  gem 'chef-zero'
  gem 'pry'
  gem 'rake'
end
