module Heirloom
  module ACL
    class S3

      def initialize(args)
        @config = args[:config]
        @region = args[:region]
        @logger = args[:logger]
        @accounts = @config.authorized_aws_accounts
      end

      def allow_read_acccess_from_accounts(args)
        bucket = args[:bucket]
        key_name = args[:key_name]
        key_folder = args[:key_folder]

        key = "#{key_folder}/#{key_name}.tar.gz"

        current_acls = s3.get_bucket_acl(bucket)

        name = current_acls['Owner']['Name']
        id = current_acls['Owner']['ID']
        grants = build_bucket_grants :id => id,
                                     :name => name,
                                     :accounts => @accounts

        @accounts.each do |a|
          @logger.info "Authorizing #{a} to s3://#{bucket}/#{key}"
        end
        s3.put_object_acl bucket, key, grants
      end

      private

      def build_bucket_grants(args)
        id = args[:id]
        name = args[:name]

        a = Array.new

        @accounts.each do |g|
          a << {
                 'Grantee' => { 'EmailAddress' => g } ,
                 'Permission' => 'READ'
               }
        end

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
