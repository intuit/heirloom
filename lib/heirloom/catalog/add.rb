module Heirloom
  class Catalog
    class Add

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
        @region = @config.metadata_region
      end

      def add_domain_to_catalog(args)
        name    = args[:name]
        regions = args[:regions]
        return false unless verifier.catalog_domain_exists?
        domain = "heirloom_#{name}"
        sdb.put_attributes 'heirloom', domain, { "regions" => regions }
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
