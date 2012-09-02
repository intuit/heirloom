module Heirloom
  class Catalog
    class Delete

      def initialize(args)
        @config = args[:config]
        @logger = @config.logger
      end

      def delete_from_catalog(args)
        name    = args[:name]
        domain  = "heirloom_#{name}"

        return false unless catalog_domain_exists?

        @logger.info "Deleting #{name} from catalog."

        sdb.delete_attributes 'heirloom', domain
      end

      def catalog_domain_exists?
        verify.catalog_domain_exists?
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
