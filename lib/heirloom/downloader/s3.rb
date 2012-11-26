require 'xmlsimple'

module Heirloom
  class Downloader
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = @config.logger
      end

      def download_file(args)
        s3.get_object args[:bucket], args[:key]
      rescue Excon::Errors::Forbidden, Excon::Errors::NotFound => e
        error = XmlSimple.xml_in e.response.body
        error['Message'].each do |msg|
          @logger.error msg
        end
        false
      end

      private

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end
    end
  end
end
