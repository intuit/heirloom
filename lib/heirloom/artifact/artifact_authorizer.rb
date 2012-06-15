require 'socket'
require 'time'

module Heirloom

  class ArtifactAuthorizer

    def initialize(args)
      @config = args[:config]
      @file = args[:file]
      @id = args[:id]
      @name = args[:name]
    end

    def authorize_artifact(args)
      @config.regions.each do |region|
        s3_uploader = Uploader::S3.new :config => @config,
                                       :region => region

        s3_uploader.upload_file :file => @file,
                                :key_name => @id,
                                :key_folder => @name
      end
    end

  end
end
