#!/usr/bin/env ruby
require 'rubygems'
require 'wonga/daemon'
require_relative 'lib/wonga/daemon/pantry_chef_environment_create_command_handler'
require_relative 'lib/wonga/pantry/chef_environment_builder'

config_path = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), 'config')
config_name = File.join(config_path, 'daemon.yml')
Wonga::Daemon.load_config(File.expand_path(config_name))
Chef::Knife.new.configure_chef
builder = Wonga::Pantry::ChefEnvironmentBuilder.new(File.expand_path(config_path), Wonga::Daemon.config, Wonga::Daemon.logger)
Wonga::Daemon.run(Wonga::Daemon::PantryChefEnvironmentCreateCommandHandler.new(builder, Wonga::Daemon.publisher, Wonga::Daemon.logger))
