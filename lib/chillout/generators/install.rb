require 'chillout/registration'

module Chillout
  class Install < ::Rails::Generators::Base
    argument :emails, :required => true, :type => :array, :banner => "EMAIL1 EMAIL2..."

    desc "Installs chillout in your app"
    def install_chillout
      project_name = File.basename(Rails.root)
      registration = Registration.new
      api_key = registration.register(project_name, emails)
      application nil, :env => :production do
        "config.chillout = { :secret => '#{api_key}' }"
      end
      puts "Chillout installed - you can find its configuration in config/environments/production.rb"
    end
  end
end
