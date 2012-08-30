module Heirloom
  class Catalog
    class Setuper

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def create_catalog_domain
        unless verifier.catalog_domain_exists?
          @logger.info "Creating catalog domain in #{@region}."
          sdb.create_domain "heirloom"
        end
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

      def verifier
        @verifier ||= AWS::Catalog::Verifier.new :config => @config
      end

    end
  end
end
