module Heirloom

  class AWS
    class SimpleDb

      def initialize(access_key, secret_key)
        @sdb = Fog::AWS::SimpleDB.new :aws_access_key_id => access_key,
                                      :aws_secret_access_key => secret_key,
                                      :region => 'us-west-1'
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
        @sdb.delete_attributes(domain, key).body
      end

    end
  end

end
