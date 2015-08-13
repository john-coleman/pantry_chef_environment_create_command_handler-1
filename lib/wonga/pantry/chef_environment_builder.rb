require 'chef'
require 'chef/knife'
require 'erb'
require 'active_support/core_ext/string/inflections'

module Wonga
  module Pantry
    class ChefEnvironmentBuilder
      def initialize(template_path, config, logger)
        @template_path = template_path
        @config = config
        @logger = logger
      end

      def build!(message)
        # required for ERB
        @message = message
        @team_name = normalize_name(@message['team_name'])
        @env_name = normalize_name(@message['environment_name'])
        @env_type = normalize_name(@message['environment_type'])
        @users = Array(@message['users']).map { |user_name| "#{@config['pantry']['domain']}\\\\\\\\#{user_name.downcase}" }

        e = Chef::Environment.new
        name = chef_environment_name(@message)
        e.name(name)
        e.description(@message['environment_description'])
        @logger.info("Building environment #{e.name}")

        # rubocop:disable Lint/Eval
        e.default_attributes = eval(ERB.new(File.read(File.join(@template_path, "#{@env_type}_environment.erb"))).result(binding))
        # rubocop:enable Lint/Eval
        e.create
        name
      end

      def normalize_name(name)
        name.parameterize.gsub('_', '-').gsub('--', '-')
      end

      def first_env(envs, name, i = 1)
        if !envs.include? "#{name}-#{i}"
          "#{name}-#{i}"
        else
          first_env(envs, name, i + 1)
        end
      end

      private

      def chef_environment_name(message)
        environments = Chef::Environment.list.keys

        if message['environment_type'] == 'CI'
          chef_environment_name = "#{@team_name}-#{@env_type}"
        else
          chef_environment_name = "#{@team_name}-#{@env_type}-#{@env_name}"
        end

        if !environments.include?(chef_environment_name)
          chef_environment_name
        else
          first_env(environments, chef_environment_name)
        end
      end
    end
  end
end
