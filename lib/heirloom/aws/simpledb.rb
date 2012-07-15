require 'fog'

module Heirloom
  module AWS
    class SimpleDB

      def initialize(args)
        @config = args[:config]
        @sdb = Fog::AWS::SimpleDB.new :aws_access_key_id => @config.access_key,
                                      :aws_secret_access_key => @config.secret_key,
                                      :region => @config.primary_region
      end

      def domains
        @sdb.list_domains.body['Domains']
      end

      def domain_exists?(domain)
        domains.include? domain
      end

      def create_domain(domain)
        @sdb.create_domain(domain) unless domain_exists?(domain)
      end

      def put_attributes(domain, key, attributes, options = {})
        @sdb.put_attributes domain, key, attributes, options
      end

      def select(query)
        @sdb.select(query).body['Items']
      end

      def delete(domain, key)
        @sdb.delete_attributes domain, key
      end

    end
  end

end
