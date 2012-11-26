require 'socket'
require 'time'

module Heirloom

  class Builder

    attr_writer :local_build

    def initialize(args)
      @config = args[:config]
      @name   = args[:name]
      @id     = args[:id]
      @domain = "heirloom_#{@name}"
      @logger = @config.logger
    end

    def build(args)
      @source        = args[:directory] ||= '.'
      @secret        = args[:secret]
      @bucket_prefix = args[:bucket_prefix]
      @file          = args[:file]
      @exclude       = args[:exclude]

      directory = Directory.new :path    => @source,
                                :file    => @file,
                                :exclude => @exclude,
                                :config  => @config

      unless directory.build_artifact_from_directory :secret => @secret
        return false
      end

      create_artifact_record
    end

    private

    def create_artifact_record
      attributes = { 'built_by'      => "#{user}@#{hostname}",
                     'built_at'      => Time.now.utc.iso8601,
                     'encrypted'     => encrypted?,
                     'bucket_prefix' => @bucket_prefix,
                     'id'            => @id }
      @logger.info "Adding entry #{@id}."
      sdb.put_attributes @domain, @id, attributes
    end

    def encrypted?
      @secret != nil
    end

    def user
      ENV['USER']
    end

    def hostname
      Socket.gethostname
    end

    def sdb
      @sdb ||= AWS::SimpleDB.new :config => @config
    end

  end
end
