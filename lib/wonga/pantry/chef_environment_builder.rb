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
        e = Chef::Environment.new
        name = chef_environment(message)
        e.name(name)
        @logger.info("Building environment #{e.name}")

        @message = message # require for ERB
        e.default_attributes = eval(ERB.new(File.read(File.join(@template_path, "jenkins_attributes.erb"))).result(binding))
        e.create
        name
      end

      private
      def chef_environment(message)
        environments = Chef::Environment.list.keys
        team_name = message["team_name"].parameterize.gsub('_', '-').gsub('--', '-')
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
