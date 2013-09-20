require 'chef'
require 'chef/knife'
require 'active_support/core_ext'
require 'erb'

module Wonga
  module Pantry
    class ChefEnvironmentBuilder
      def initialize(message, logger)
        @message = message
        @logger = logger
      end

      def build!
        e = Chef::Environment.new
        @name = chef_environment
        e.name(@name)
        @logger.info("Building environment #{e.name}")
        e.default_attributes = attributes
        e.create
      end

      def chef_environment
        environments = Chef::Environment.list.keys
        team_name = @message[:team_name].underscore.parameterize.gsub('_', '-').gsub('--', '-')
        if !environments.include?(team_name)
          team_name
        else
          first_env(environments, team_name)
        end
      end

      def first_env(envs, team, i=1)
        if !envs.include? "#{team}-#{i}"
          "#{team}-#{i}"
        else
          first_env(envs, team, i+1)
        end
      end
    end
  end
end
