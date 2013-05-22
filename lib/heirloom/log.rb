require 'logger'

module Heirloom
  module Log

    def self.included(base)
      base.extend(self)
    end
    
    def log
      @logger ||= Logger.new($stdout).tap do |l|
        l.datetime_format = '%Y-%m-%dT%H:%M:%S%z'
        l.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} #{severity} : #{msg}\n"
        end
        l.level = Logger::INFO
      end
    end
    
    def log_level=(level)
      self.log.level = Logger.const_get level.upcase
    end

  end
end
