module Heirloom
  class Catalog
    class Delete

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def delete_domain_from_catalog(args)
        name    = args[:name]
        regions = args[:regions]
        return false unless verifier.catalog_domain_exists?
        domain = "heirloom_#{name}"
        sdb.delete_attributes 'heirloom', domain
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
