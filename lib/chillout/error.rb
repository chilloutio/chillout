require 'ostruct'

module Chillout
  class Error

    attr_reader :exception
    attr_reader :environment

    def initialize(exception, environment = {})
      @exception   = exception
      @environment = environment
      @nullObject  = OpenStruct.new
    end

    def exception_class
      exception.class.name
    end

    def message
      exception.message
    end

    def backtrace
      exception.backtrace
    end

    def file
      backtrace.first.split(":").first rescue nil
    end

    def controller
      environment['action_controller.instance'] || @nullObject
    end

    def controller_name
      controller.controller_name
    end

    def controller_action
      controller.action_name
    end

    def current_user
      environment['current_user'] || @nullObject
    end

    def current_user_id
      current_user.id if current_user.respond_to?(:id)
    end

    def current_user_email
      current_user.email if current_user.respond_to?(:email)
    end

    def current_user_full_name
      current_user.full_name if current_user.respond_to?(:full_name)
    end

  end
end
