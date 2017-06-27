require 'logger'
require 'chillout/version'


module Chillout
  class Config

    DEFAULT_HOSTNAME      = "api.chillout.io"
    DEFAULT_PORT          = 443
    DEFAULT_NOTIFIER_NAME = "Chillout"
    DEFAULT_NOTIFIER_URL  = "http://github.com/chilloutio/chillout"

    attr_accessor :environment
    attr_accessor :notifier_name
    attr_accessor :notifier_url
    attr_accessor :version
    attr_accessor :platform
    attr_accessor :hostname
    attr_accessor :port
    attr_accessor :api_key
    attr_writer   :authentication_user
    attr_writer   :authentication_password
    attr_accessor :logger
    attr_accessor :ssl
    attr_reader   :strategy
    attr_accessor :max_queue

    def initialize(api_key = nil)
      @api_key = api_key
      @hostname = DEFAULT_HOSTNAME
      @port = DEFAULT_PORT
      @notifier_name = DEFAULT_NOTIFIER_NAME
      @notifier_url = DEFAULT_NOTIFIER_URL
      @version = VERSION
      @logger = Logger.new(STDOUT)
      @ssl = true
      @strategy = :thread
      @max_queue = 5_000

      @authentication_user = nil
      @authentication_password = nil
    end

    def update(options)
      options.each do |name, value|
        send("#{name}=", value)
      end
    end

    def strategy=(name)
      name = name.to_sym
      precondition = {
        active_job: -> { defined?(ActiveJob) or raise ArgumentError, "ActiveJob is not enabled" },
        thread: -> {},
      }.fetch(name, -> { raise ArgumentError, "unknown strategy" })
      precondition.call
      @strategy = name
    end

    def authentication_user
      @authentication_user || api_key
    end

    def authentication_password
      @authentication_password || api_key
    end

    def to_s
      <<-eos
 * hostname: #{hostname}
 * port: #{port}
 * ssl: #{ssl}
      eos
    end

  end
end
