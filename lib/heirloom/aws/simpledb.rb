module Heirloom

  class AWS
    class SimpleDb

      def initialize(args)
        @config = args[:config]
        @sdb = Fog::AWS::SimpleDB.new :aws_access_key_id => @config.access_key,
                                      :aws_secret_access_key => @config.secret_key,
                                      :region => @config.region
      end

      def domains
        @sdb.list_domains.body['Domains']
      end

      def create_domain(domain)
        @sdb.create_domain(domain) unless domains.include? domain
      end

      def put_attributes(domain, key, args)
        @sdb.put_attributes domain, key, args
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
