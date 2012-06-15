module Heirloom
  module Destroyer
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
      end

      def destroy_file(args)
        key_name = args[:key_name]
        key_folder = args[:key_folder]
        bucket = args[:bucket]

        s3.delete_object bucket, "#{key_folder}/#{key_name}"
      end

      private

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end

    end
  end
end
