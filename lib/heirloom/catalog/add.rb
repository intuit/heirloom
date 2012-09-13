module Heirloom
  class Catalog
    class Add

      def initialize(args)
        @config  = args[:config]
        @name    = args[:name]
        @logger  = @config.logger
      end

      def add_to_catalog(args)
        regions       = args[:regions]
        bucket_prefix = args[:bucket_prefix]

        @logger.info "Adding #{@name} to catalog."

        sdb.put_attributes 'heirloom', 
                           "heirloom_#{@name}", 
                           { "regions" => regions, 
                             "bucket_prefix" => bucket_prefix }

      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
