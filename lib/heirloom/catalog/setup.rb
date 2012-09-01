module Heirloom
  class Catalog
    class Setup

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def create_catalog_domain
        unless verify.catalog_domain_exists?
          @logger.info "Creating catalog domain in #{@region}."
          sdb.create_domain "heirloom"
        end
      end

      private

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

      def verify
        @verify ||= Catalog::Verify.new :config => @config
      end

    end
  end
end
