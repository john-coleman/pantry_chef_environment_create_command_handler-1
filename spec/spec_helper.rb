require 'aws'
require 'chef'
require 'rspec/fire'
require 'chef/knife'
require 'chef_zero/server'
require 'spec_support/shared_daemons'
require_relative '../lib/wonga/pantry/chef_helper'

server = ChefZero::SingleServer

Chef::Knife.new.configure_chef
Chef::Config[:chef_server_url] = 'http://127.0.0.1:8889'

RSpec.configure do |config|
  config.include(RSpec::Fire)

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:each) do
    ChefZero::SingleServer.instance.clean
  end  
end
