unless ENV["SKIP_COV"]
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
end

require 'aws'
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

RSpec.configure do |config|
  config.order = "random"

  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end
end
