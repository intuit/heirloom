require 'fog'

module Heirloom
  module AWS
    class SimpleDB

      def initialize(args)
        @config = args[:config]
        
        fog_args = { :region => @config.metadata_region }

        if @config.use_iam_profile
          fog_args[:use_iam_profile] = true
        else
          fog_args[:aws_access_key_id]     = @config.access_key
          fog_args[:aws_secret_access_key] = @config.secret_key
        end

        @sdb = Fog::AWS::SimpleDB.new fog_args
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

      def delete_domain(domain)
        @sdb.delete_domain(domain)
      end

      def domain_empty?(domain)
        count(domain).zero?
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

      def count(domain)
        body = @sdb.select("SELECT count(*) FROM `#{domain}`").body
        body['Items']['Domain']['Count'].first.to_i
      end

      def item_count(domain, item)
        query = "SELECT count(*) FROM `#{domain}` WHERE itemName() = '#{item}'"
        @sdb.select(query).body['Items']['Domain']['Count'].first.to_i
      end

    end
  end

end
