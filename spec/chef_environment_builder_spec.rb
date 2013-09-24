require 'spec_helper'

require_relative "../lib/wonga/pantry/chef_environment_builder"
describe Wonga::Pantry::ChefEnvironmentBuilder do

  let(:logger) { instance_double('Logger').as_null_object }
  let(:message) { {"team_name"=> 'Some Name', "domain"=> 'test-domain', "jenkins_host_name"=> 'some-name'} }
  let(:team_name) { message['team_name'].underscore.parameterize.gsub('_', '-').gsub('--', '-') }
  let(:path) { File.join(File.dirname(__FILE__), '../config') }
  subject { described_class.new(path, logger) }

  describe "#build!" do
    it "returns environment name" do
      expect(subject.build!(message)).to eq('some-name')
    end

    it "sets unique environment name" do
      subject.build!(message)
      expect(subject.build!(message)).to eq('some-name-1')
    end

    context "creates new Chef environment" do
      before(:each) do
        subject.build!(message)
      end

      let(:environment) { Chef::Environment.load("some-name") }

      %w( authorization build_agent build_essential jenkins nginx openssh).each do |group|
        it "with #{group} information" do
          expect(environment.default_attributes).to have_key(group)
        end
      end

      it "with address for jenkins" do
        jenkins = environment.default_attributes['jenkins']['server']
        expect(jenkins['host']).to eq "#{team_name}.#{message['domain']}"
        expect(jenkins["url"]).to include "#{team_name}.#{message['domain']}"
      end
    end

    context "for team with restricted symbols in name" do
      let(:team_name) { 'some .,+_name?' }

      it "creates new Chef environment" do
        expect(subject.build!(message)).to eq('some-name')
      end
    end
  end
end
