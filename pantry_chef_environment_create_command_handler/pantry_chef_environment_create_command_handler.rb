module Wonga
  module Daemon
    class PantryChefEnvironmentCreateCommandHandler
      def initialize(builder, publisher, logger)
        @builder = builder
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        @logger.info("Received message: #{message}")
        message["chef_environment"] = @builder.build!(message)
        @logger.info("Message for #{message["team_name"]} processed. publishing")
        @publisher.publish(message)
      end
    end
  end
end