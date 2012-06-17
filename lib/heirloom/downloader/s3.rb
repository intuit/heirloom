module Heirloom
  module Downloader
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = args[:logger]
      end

      def download_file(args)
        s3.get_object args[:bucket], args[:key]
      end

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end
    end
  end
end
