unless ENV['SKIP_COV']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
end

require 'chef'
require 'chef/knife'
require 'spec_support/shared_daemons'
require 'chef_zero'
require 'chef_zero/server'

class ChefZero::SingleServer
  def initialize
    @server = ChefZero::Server.new(port: 8889)
    @server.start_background
  end
  include Singleton

  def clean
    @server.clear_data
  end
end

Chef::Knife.new.configure_chef
Chef::Config[:chef_server_url] = 'http://127.0.0.1:8889'
Chef::Config[:client_key] = File.join(File.expand_path(File.dirname(File.realpath(__FILE__))), 'chef.pem')
Chef::Config[:node_name] = 'test_name'

RSpec.configure do |config|
  config.order = 'random'

  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end

  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
