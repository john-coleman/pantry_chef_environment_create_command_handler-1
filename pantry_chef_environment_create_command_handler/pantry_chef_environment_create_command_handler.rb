module Wonga
  module Daemon
    class PantryChefEnvironmentCreateCommandHandler
      def initialize(publisher, config)
        @publisher = publisher
        @config = config
      end

      def handle_message(message)
        Chef::Knife.new.configure_chef
        chef_builder = ChefEnvironmentBuilder.new(message, logger)
        chef_builder.build!
        message[:chef_environment] = chef_builder.name
        @publisher.publish(message)
      end
    end
  end
end