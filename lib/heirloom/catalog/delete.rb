module Heirloom
  class Catalog
    class Delete

      def initialize(args)
        @config = args[:config]
        @name    = args[:name]
        @logger = @config.logger
      end

      def delete_from_catalog
        domain  = "heirloom_#{@name}"

        return false unless catalog_domain_exists?

        @logger.info "Deleting #{@name} from catalog."

        sdb.delete 'heirloom', domain
      end

      private

      def catalog_domain_exists?
        verify.catalog_domain_exists?
      end

      def sdb
        @sdb ||= AWS::SimpleDB.new :config => @config
      end

      def verify
        @verify ||= Catalog::Verify.new :config => @config
      end

    end
  end
end
