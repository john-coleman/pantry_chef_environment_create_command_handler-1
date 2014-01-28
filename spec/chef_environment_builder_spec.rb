require 'spec_helper'
require 'json'

require_relative "../lib/wonga/pantry/chef_environment_builder"
describe Wonga::Pantry::ChefEnvironmentBuilder do

  let(:logger) { instance_double('Logger').as_null_object }
  let(:team_name) { 'Some name TLA' }
  let(:path) { File.join(File.dirname(__FILE__), '../config') }
  subject { described_class.new(path, logger) }

  describe "#build!" do
    context "when creating a CI environment" do
      #let(:message) {{"team_name"=> team_name,"domain"=> 'test-domain',"environment_type"=>"CI",}}
      let(:message) {
        {
          "team_name" => team_name,
          "description" => "A CI Environment",
          "domain"=> "test-domain",
          "environment_name" => "Jenkins",
          "environment_type"=>"CI"
        }
      }

      it "returns environment name" do
        expect(subject.build!(message)).to eq('some-name-tla-ci-jenkins')
      end

      it "sets unique environment name" do
        subject.build!(message)
        expect(subject.build!(message)).to eq('some-name-tla-ci-jenkins-1')
      end

      context "creates new Chef environment" do
        before(:each) do
          subject.build!(message)
        end

        let(:environment) { Chef::Environment.load("some-name-tla-ci-jenkins") }

        %w( authorization build_agent build_essential java jenkins nginx openssh).each do |group|
          it "with #{group} information" do
            expect(environment.default_attributes).to have_key(group)
          end
        end

        it "with address for jenkins" do
          jenkins = environment.default_attributes['jenkins']['server']
          expect(jenkins['host']).to eq "some-name-tla.#{message['domain']}"
        end

        it "with url for jenkins" do
          jenkins = environment.default_attributes['jenkins']['server']
          expect(jenkins["url"]).to include "some-name-tla.#{message['domain']}"
        end
      end
    end

    context "when creating an INT environment" do
      let(:message) {
        {
          "team_name" => team_name,
          "description" => "An INT Environment",
          "domain"=> "test-domain",
          "environment_name" => "TED",
          "environment_type"=>"INT"
        }
      }

      it "returns environment name" do
        expect(subject.build!(message)).to eq('some-name-tla-int-ted')
      end

      it "sets unique environment name" do
        subject.build!(message)
        expect(subject.build!(message)).to eq('some-name-tla-int-ted-1')
      end

      context "creates new Chef environment" do
        before(:each) do
          subject.build!(message)
        end

        let(:environment) { Chef::Environment.load("some-name-tla-int-ted") }

        %w( api_server authorization frontend_server iis newrelic nginx wonga wonga_splunk ).each do |group|
          it "with #{group} information" do
            expect(environment.default_attributes).to have_key(group)
          end
        end

        it "with url for api endpoint" do
          api_endpoint = environment.default_attributes['api_server']['api']
          expect(api_endpoint["host_header"]).to include "int.some-name-tla.#{message['domain']}"
        end
      end
    end
  end

  describe "#normalize_team_name" do
    context "processes names with illegal characters" do
      let(:team_name) { 'some .,+_name?' }
      it "normalizes the name" do
        expect(subject.normalize_name(team_name)).to eq('some-name')
      end
    end

    context "processes names with mixed case" do
      let(:team_name) { 'PayLater UK' }
      it "creates new Chef environment" do
        expect(subject.normalize_name(team_name)).to eq('paylater-uk')
      end
    end
  end

  describe "#first_envs" do
    let(:env_list_1) {
      list = Chef::Environment.list.keys
      list << "some-env"
    }
    context "When environment name already exists" do
      it "returns environment name with counter " do
        expect(subject.first_env(env_list_1, 'some-env')).to eq('some-env-1')
      end
    end

    context "When the suffixed environment name already exists" do
      let(:env_list_2) { env_list_1 << "some-env-1" }
      it "returns environment name with incremented counter" do
        expect(subject.first_env(env_list_2, 'some-env')).to eq('some-env-2')
      end
    end
  end
end
