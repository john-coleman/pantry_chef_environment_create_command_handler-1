require 'spec_helper'

require_relative "../lib/wonga/pantry/chef_environment_builder"
describe Wonga::Pantry::ChefEnvironmentBuilder do
  
  let(:logger) { instance_double('Logger').as_null_object }
  let(:message) { {team_name: 'some-name', domain: 'test-domain', jenkins_host_name: 'some-name'} }
  let(:path) { File.join(File.dirname(__FILE__), '../config') }
  subject { described_class.new(path, logger) }

  describe "#chef_environment" do
    it "returns prepared name" do
      expect(subject.chef_environment(message)).to eq('some-name')
    end
  end

  describe "#build!" do
    before(:each) do
      subject.build!(message)
    end

    let(:environment) { Chef::Environment.load("some-name") }
    %w( authorization build_agent build_essential jenkins nginx openssh).each do |group|
      it "creates new Chef environment with #{group} information" do
        expect(environment.default_attributes).to have_key(group)
      end
    end

    it "sets address for jenkins" do
      jenkins = environment.default_attributes['jenkins']['server']
      expect(jenkins['host']).to eq "#{message['team_name']}.#{message['domain']}"
      expect(jenkins["url"]).to include "#{message['team_name']}.#{message['domain']}"
    end

    context "for team with restricted symbols in name" do
      let(:team_name) { 'some .,+_name?' }

      it "creates new Chef environment" do
        expect(environment).not_to be_nil
      end
    end
  end
end
