namespace :chillout do
  desc "Check chillout integration"
  task :check do
    Rails.initialize!
    config = Rails.configuration.chillout
    client = Chillout::Client.new(config[:secret], config.reject{|x| x == :secret})
    check_result = client.check_api_connection

    if check_result.successful?
      puts "Chillout API available."
    elsif check_result.has_problem_with_authorization?
      puts "Chillout API available, but project couldn't authorize."
    else
      puts "Chillout API not available for given configuration:"
      puts client.config.to_s
    end
  end
end
