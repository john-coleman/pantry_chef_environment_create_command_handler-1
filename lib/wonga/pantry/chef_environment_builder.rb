require 'chef'
require 'chef/knife'
require 'active_support/core_ext'

module Wonga
  module Pantry
    class ChefEnvironmentBuilder
      def initialize(team_name, domain, jenkins, logger)
        @team_name = team_name
        @domain = domain
        @jenkins_host_name = jenkins
        @logger = logger
      end

      def build!
        e = Chef::Environment.new
        @name = chef_environment
        e.name(@name)
        @logger.info("Building environment #{e.name}")        
        e.default_attributes = attributes
        e.create
      end

      def name
        @name
      end

      def chef_environment
        environments = Chef::Environment.list.keys
        team_name = @team_name.underscore.parameterize.gsub('_', '-').gsub('--', '-')
        if !environments.include?(team_name)
          team_name
        else
          first_env(environments, team_name)
        end
      end

      def first_env(envs, team, i=1)
        if !envs.include? "#{team}-#{i}"
          "#{team}-#{i}"
        else
          first_env(envs, team, i+1)
        end
      end

      private
      def attributes
        {
          "authorization" => {
            "sudo" => {
              "groups" => [ "sysadmin" ],
              "users" => [ "deploy", "ubuntu" ],
              "passwordless" => true,
              "include_sudoers_d" => true
            }
          },
          "build_agent" => {
            "git_ssh_path" => "C:\\Jenkins",
            "jenkins_working_directory" => "C:\\Jenkins"
          },
          "build_essential" => {
            "compiletime" => true
          },
          "jenkins" => {
            "http_proxy" => {
              "host_name" =>"#{@jenkins_host_name}.#{@domain}",
              "variant" => "nginx"
            },
            "node" => {
              "auth_ad_domain" => "EXAMPLE",
              "auth_enabled" => true,
              "auth_user" => "ProvisionerUsername",
              "auth_password" => "ProvisionerPassword",
              "home" => "C:\\Jenkins"
            },
            "server" => {
              "host" => "#{@jenkins_host_name}.#{@domain}",
              "plugins" => [
                "active-directory",
                "ansicolor",
                "git",
                "git-client",
                "github",
                "greenballs",
                "htmlpublisher",
                "ldap",
                "mailer",
                "msbuild",
                "parameterized-trigger",
                "radiatorviewplugin",
                "scm-sync-configuration",
                "translation",
                "versionnumber"
              ],
              "port" => 8080,
              "url" => "http://#{@jenkins_host_name}.#{@domain}:8080"
            }
          },
          "nginx" => {
            "default_site_enabled" => false
          },
          "openssh" => {
            "client" => {
              "strict_host_key_checking" => "no"
            }
          }
        }
      end
    end
  end
end
