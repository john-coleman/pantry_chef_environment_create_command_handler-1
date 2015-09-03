require 'spec_helper'
require 'json'
require 'yaml'

require_relative '../../../../lib/wonga/pantry/chef_environment_builder'

RSpec.describe Wonga::Pantry::ChefEnvironmentBuilder do
  let(:template_path) { File.join(File.dirname(__FILE__), '../../../../config') }
  let(:config) { YAML.load_file(File.join(template_path, 'daemon.yml.sample'))['test'] }
  let(:domain) { 'test-domain' }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:team_name) { 'Some name TLA' }

  subject { described_class.new(template_path, config, logger) }

  describe '#build!' do
    context 'when creating a CI environment' do
      let(:message) do
        {
          'team_name' => team_name,
          'domain' => domain,
          'environment_description' => 'A CI Environment',
          'environment_name' => 'Jenkins',
          'environment_type' => 'CI',
          'sonar' => {
            'server_hostname' => 'sonar-testhostname.example.com',
            'jdbc_username' => 'ThisTestSonarUser'
          }
        }
      end
      let(:sonar_hostname) { message['sonar']['server_hostname'] }
      let(:sonar_jdbc_username) { message['sonar']['jdbc_username'] }

      it 'returns environment name' do
        expect(subject.build!(message)).to eq('some-name-tla-ci')
      end

      it 'sets unique environment name' do
        subject.build!(message)
        expect(subject.build!(message)).to eq('some-name-tla-ci-1')
      end

      context 'creates new chef_environment' do
        before(:each) do
          subject.build!(message)
        end

        let(:environment) { Chef::Environment.load('some-name-tla-ci') }

        it 'sets environment description' do
          expect(environment.description).to eq(message['environment_description'])
        end

        %w( authorization build_agent build-essential jenkins iis nginx openssh
            postfix snmp wonga wonga_windows wonga_splunk winbind ).each do |group|
          it "with #{group} information" do
            expect(environment.default_attributes).to have_key(group)
          end
        end

        it 'with jenkins server hostname' do
          jenkins = environment.default_attributes['jenkins']['server']
          expect(jenkins['host']).to eq "some-name-tla.#{domain}"
        end

        it 'with jenkins server url' do
          jenkins = environment.default_attributes['jenkins']['server']
          expect(jenkins['url']).to include "some-name-tla.#{domain}"
        end

        it 'with sonar server url' do
          sonar = environment.default_attributes['build_agent']['sonar']
          expect(sonar['host_url']).to eq "http://#{sonar_hostname}:9000/"
        end

        it 'with sonar server jdbc connection parameters' do
          sonar = environment.default_attributes['build_agent']['sonar']
          expect(sonar['jdbc_url']).to eq "jdbc:mysql://#{sonar_hostname}:3306/sonar?useUnicode=true&amp;characterEncoding=utf8"
          expect(sonar['jdbc_username']).to eq sonar_jdbc_username
          expect(sonar['jdbc_password']).to eq 'ATestSonarPass'
        end

        it 'sets users' do
          expect(environment.default_attributes['authorization']['sudo']['users']).to be_include 'ubuntu'
          expect(environment.default_attributes['authorization']['sudo']['users']).to be_include 'deploy'
        end

        it 'sets git ssh hosts' do
          expect(environment.default_attributes['wonga']['jenkins']['git_ssh_hosts']).to include {
            {
              'host' => 'git.example.com',
              'StrictHostKeyChecking' => 'no',
              'User' => 'gituser'
            }
          }
        end

        context 'when team users are passed' do
          let(:message) do
            {
              'team_name' => team_name,
              'domain' => domain,
              'environment_description' => 'A CI Environment',
              'environment_name' => 'Jenkins',
              'environment_type' => 'CI',
              'sonar' => {
                'server_hostname' => 'sonar-testhostname.example.com',
                'jdbc_username' => 'ThisTestSonarUser'
              },
              'users' => [user]
            }
          end
          let(:user) { 'evil.user' }
          let(:config_domain) { 'DOMAIN' }

          let(:config) do
            old_config = super()
            old_config['pantry'] = { 'domain' => config_domain }
            old_config
          end

          it 'grants them sudo' do
            expect(environment.default_attributes['authorization']['sudo']['users']).to be_include("#{config_domain}\\\\#{user}")
          end
        end
      end
    end

    context 'when creating a STG environment' do
      let(:message) do
        {
          'team_name' => team_name,
          'domain' => domain,
          'environment_description' => 'A STG Environment',
          'environment_name' => 'TED',
          'environment_type' => 'STG',
          'product' => 'YY',
          'region' => 'ZZ'
        }
      end
      let(:prod_ns) { message['product'].downcase }
      let(:reg_ns) { message['region'].downcase }
      let(:env_ns) { message['environment_type'].downcase }

      it 'returns environment name' do
        expect(subject.build!(message)).to eq('some-name-tla-stg-ted')
      end

      it 'sets unique environment name' do
        subject.build!(message)
        expect(subject.build!(message)).to eq('some-name-tla-stg-ted-1')
      end

      context 'creates new chef_environment' do
        before(:each) do
          subject.build!(message)
        end

        let(:environment) { Chef::Environment.load('some-name-tla-stg-ted') }
        let(:fe_site) { environment.default_attributes['frontend_server']['sites'].first }

        it 'sets environment description' do
          expect(environment.description).to eq(message['environment_description'])
        end

        %w( authorization build_agent build-essential drush frontend_server iis newrelic nginx
            openssh postfix snmp wonga wonga_windows wonga_splunk winbind ).each do |group|
          it "with #{group} information" do
            expect(environment.default_attributes).to have_key(group)
          end
        end

        %w( api callbacks cdn ).each do |endpoint|
          it "with frontend_server #{endpoint}_endpoint url" do
            expect(fe_site["#{endpoint}_endpoint"]).to eq "http://#{endpoint}.#{prod_ns}.#{reg_ns}.#{env_ns}.some-name-tla.#{domain}"
          end
        end

        it 'with frontend_server static_server_url' do
          fe_site = environment.default_attributes['frontend_server']['sites'].first
          expect(fe_site['static_server_url']).to eq "http://static.#{prod_ns}.#{reg_ns}.#{env_ns}.some-name-tla.#{domain}"
        end

        it 'with frontend_server vhost_name' do
          fe_site = environment.default_attributes['frontend_server']['sites'].first
          expect(fe_site['vhost_name']).to eq "#{prod_ns}.#{reg_ns}.#{env_ns}.some-name-tla.#{domain}"
        end

        context 'when team users are provided' do
          let(:message) do
            {
              'team_name' => team_name,
              'domain' => domain,
              'environment_description' => 'A STG Environment',
              'environment_name' => 'TED',
              'environment_type' => 'STG',
              'product' => 'YY',
              'region' => 'ZZ',
              'users' => [user]
            }
          end
          let(:user) { 'evil.user' }
          let(:config_domain) { 'DOMAIN' }

          let(:config) do
            old_config = super()
            old_config['pantry'] = { 'domain' => config_domain }
            old_config
          end

          it 'grants them sudo' do
            expect(environment.default_attributes['authorization']['sudo']['users']).to be_include("#{config_domain}\\\\#{user}")
          end
        end
      end
    end
  end

  describe '#normalize_team_name' do
    context 'processes names with illegal characters' do
      let(:team_name) { 'some .,+_name?' }
      it 'normalizes the name' do
        expect(subject.normalize_name(team_name)).to eq('some-name')
      end
    end

    context 'processes names with mixed case' do
      let(:team_name) { 'CamelCase OMG' }
      it 'creates new Chef environment' do
        expect(subject.normalize_name(team_name)).to eq('camelcase-omg')
      end
    end
  end

  describe '#first_envs' do
    let(:env_list_1) do
      list = Chef::Environment.list.keys
      list << 'some-env'
    end

    context 'when environment name already exists' do
      it 'returns environment name with counter ' do
        expect(subject.first_env(env_list_1, 'some-env')).to eq('some-env-1')
      end
    end

    context 'when the suffixed environment name already exists' do
      let(:env_list_2) { env_list_1 << 'some-env-1' }
      it 'returns environment name with incremented counter' do
        expect(subject.first_env(env_list_2, 'some-env')).to eq('some-env-2')
      end
    end
  end
end
