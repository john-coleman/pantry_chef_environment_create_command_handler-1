require_relative '../lib/wonga/pantry/chef_environment_builder'

module Wonga
  module Daemon
    class PantryChefEnvironmentCreateCommandHandler
      def initialize(publisher, logger)
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        @logger.info("Received message: #{message}")
        Chef::Knife.new.configure_chef
        chef_builder = Wonga::Pantry::ChefEnvironmentBuilder.new(
          message,
          logger
        )
        chef_builder.build!
        message["chef_environment"] = chef_builder.name
        @logger.info("Message for #{message["team_name"]} processed. publishing")
        @publisher.publish(message)
      end
    end
  end
end