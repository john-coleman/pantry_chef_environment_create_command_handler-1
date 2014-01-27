require 'chef'
require 'chef/knife'
require 'erb'
require 'active_support/core_ext'

module Wonga
  module Pantry
    class ChefEnvironmentBuilder
      def initialize(template_path, logger)
        @template_path = template_path
        @logger = logger
      end

      def build!(message)
        # required for ERB
        @message = message
        @team_name = normalize_name(@message['team_name'])
        @env_name = normalize_name(@message['environment_name'])
        @env_type = normalize_name(@message['environment_type'])

        e = Chef::Environment.new
        name = chef_environment_name(@message)
        e.name(name)
        e.description(@message['description'])
        @logger.info("Building environment #{e.name}")

        e.default_attributes = eval(ERB.new(File.read(File.join(@template_path, "#{@env_type}_environment.erb"))).result(binding))
        e.create
        name
      end

      def normalize_name(name)
        name.parameterize.gsub('_', '-').gsub('--', '-')
      end

      def first_env(envs, name, i=1)
        if !envs.include? "#{name}-#{i}"
          "#{name}-#{i}"
        else
          first_env(envs, name, i+1)
        end
      end

      private
      def chef_environment_name(message)
        environments = Chef::Environment.list.keys
        chef_environment_name = "#{@team_name}-#{@env_type}-#{@env_name}"
        if !environments.include?(chef_environment_name)
          chef_environment_name
        else
          first_env(environments, chef_environment_name)
        end
      end

    end
  end
end
