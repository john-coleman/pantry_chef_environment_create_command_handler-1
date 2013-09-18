require 'spec_helper'

require_relative "../../lib/wonga/pantry/chef_environment_builder"
require_relative '../../pantry_chef_environment_create_command_handler/pantry_chef_environment_create_command_handler'

describe Wonga::Daemon::PantryChefEnvironmentCreateCommandHandler do
  let(:publisher) { instance_double('Publisher').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  subject(:env_handler) { described_class.new(publisher, logger) }
  it_behaves_like 'handler'
end

describe Wonga::Pantry::ChefEnvironmentBuilder do
  let(:logger) { instance_double('Logger').as_null_object }
  let(:team_name) { 'some-name' }
  let(:domain) { 'test-domain' }
  let(:jenkins_host_name) { 'some-name' }
  subject { 
    described_class.new(team_name, domain, jenkins_host_name, logger) 
  }

  describe "#chef_environment" do
    it "returns prepared name" do
      expect(subject.chef_environment).to eq('some-name')
    end
  end

  describe "#build!" do
    before(:each) do
      subject.build!
    end

    let(:environment) { Chef::Environment.load("some-name") }
    %w( authorization build_agent build_essential jenkins nginx openssh).each do |group|
      it "creates new Chef environment with #{group} information" do
        expect(environment.default_attributes).to have_key(group)
      end
    end

    it "sets address for jenkins" do
      jenkins = environment.default_attributes['jenkins']['server']
      expect(jenkins['host']).to eq "#{team_name}.#{domain}"
      expect(jenkins["url"]).to include("#{team_name}.#{domain}")
    end

    context "for team with restricted symbols in name" do
      let(:team_name) { 'some .,+_name?' }

      it "creates new Chef environment" do
        expect(environment).not_to be_nil
      end
    end
  end
end


