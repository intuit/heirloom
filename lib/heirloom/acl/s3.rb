module Heirloom
  module ACL
    class S3

      attr_accessor :accounts, :config, :logger, :region

      def initialize(args)
        self.config = args[:config]
        self.region = args[:region]
        self.logger = config.logger
      end

      def allow_read_access_from_accounts(args)
        bucket = args[:bucket]
        key_name = args[:key_name]
        key_folder = args[:key_folder]
        accounts = args[:accounts]

        key = "#{key_folder}/#{key_name}.tar.gz"

        current_acls = s3.get_bucket_acl bucket

        name = current_acls['Owner']['Name']
        id = current_acls['Owner']['ID']

        grants = build_bucket_grants :id => id,
                                     :name => name,
                                     :accounts => accounts

        accounts.each do |a|
          logger.debug "Authorizing #{a} to s3://#{bucket}/#{key}."
        end
        s3.put_object_acl bucket, key, grants
      end

      private

      def build_bucket_grants(args)
        id = args[:id]
        name = args[:name]
        accounts = args[:accounts]

        a = Array.new

        # Add each account email as read access
        accounts.each do |g|
          a << {
                 'Grantee' => { 'EmailAddress' => g } ,
                 'Permission' => 'READ'
               }
        end

        # Grand owner full access
        a << { 'Grantee' => { 'DisplayName' => name, 'ID' => id },
               'Permission' => 'FULL_CONTROL'
             }

        {
          'Owner' => {
            'DisplayName' => name,
            'ID' => id
          },
          'AccessControlList' => a
        }
      end

      def s3
        @s3 ||= AWS::S3.new :config => @config,
                            :region => @region
      end

    end
  end
end
