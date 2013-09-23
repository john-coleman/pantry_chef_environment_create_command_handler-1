require 'spec_helper'

require_relative "../../lib/wonga/pantry/chef_environment_builder"
require_relative '../../pantry_chef_environment_create_command_handler/pantry_chef_environment_create_command_handler'

describe Wonga::Daemon::PantryChefEnvironmentCreateCommandHandler do
  let(:publisher) { instance_double('Publisher').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:builder) { instance_double('Wonga::Pantry::ChefEnvironmentBuilder', build!: 'test')}
  
  subject(:env_handler) { described_class.new(builder, publisher, logger) }
  it_behaves_like 'handler'
end
