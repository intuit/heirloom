module Heirloom
  class Catalog
    class Verifier

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def catalog_domain_exists?
        if sdb.domain_exists? 'heirloom'
          @logger.debug "Catalog domain exists in #{@region}."
          true
        else
          @logger.debug "Catalog domain does not exist in #{@region}."
          false
        end
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

    end
  end
end
