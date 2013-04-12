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
      puts "Chillout installed - you can find its configuration in config/environments/production.rb."
    rescue Registration::NotRegisteredByLimit
      puts "Chillout not installed - we're currently out of limit for new projects. Please try again later or send us email on info@chillout.io."
    rescue Registration::NotRegisteredByInvalidData
      puts "Chillout not installed - you've passed incorrect data."
    rescue Registration::NotRegisteredByAccident
      puts "Chillout not installed - our API returned a silly response. Please send us email on info@chillout.io."
    rescue Registration::NotRegisteredByCommunicationError
      puts "Chillout not installed - we couldn't get response from our API. Please check if you can access https://chillout.io/ with your browser."
    end
  end
end
