require 'spec_helper'

require_relative '../../../../lib/wonga/pantry/chef_environment_builder'
require_relative '../../../../lib/wonga/daemon/pantry_chef_environment_create_command_handler'

RSpec.describe Wonga::Daemon::PantryChefEnvironmentCreateCommandHandler do
  let(:publisher) { instance_double('Publisher').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:builder) { instance_double('Wonga::Pantry::ChefEnvironmentBuilder', build!: 'test') }

  subject(:env_handler) { described_class.new(builder, publisher, logger) }
  it_behaves_like 'handler'

  it 'sends message with new environment name' do
    message = { 'domain' => 'wonga.com' }
    allow(publisher).to receive(:publish) do |hash|
      expect(message.all? { |key, value| hash[key] == value }).to be_truthy
      expect(message['chef_environment']).to eq('test')
    end

    subject.handle_message message
    expect(publisher).to have_received(:publish)
  end
end
