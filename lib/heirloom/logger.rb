require 'logger'

module Heirloom
  module Logging
    
    def logger
      Logging.logger
    end

    def self.logger(args = {})
      log_level = args[:log_level] ||= 'info'
      @logger ||= Logger.new(STDOUT).tap do |l|
        l.datetime_format = '%Y-%m-%dT%H:%M:%S%z'
        l.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} #{severity} : #{msg}\n"
        end
        l.level = log_level.upcase
      end
    end
  end

  class HeirloomLogger
    
    require 'forwardable'

    extend Forwardable
    include Logging

    def_delegators :@logger, :debug, :error, :info, :warn

    def initialize(args = {})
      @log_level = args[:log_level] ||= 'info'
      @logger    = args[:logger] ||= new_logger(args)
    end

    def self.logger(args = {})
      @logger ||= Logging.logger(args)
    end

    private

    def new_logger(args)
      Logger.new(STDOUT).tap do |l|
        l.datetime_format = '%Y-%m-%dT%H:%M:%S%z'
        l.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} #{severity} : #{msg}\n"
        end
        l.level = logger_level
      end
    end

    def logger_level
      Logger.const_get @log_level.upcase
    end

  end


end
