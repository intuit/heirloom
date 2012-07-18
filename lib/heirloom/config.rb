module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :regions, 
                  :primary_region, :bucket_prefix, :authorized_aws_accounts,
                  :logger, :simpledb

    def initialize(args = {})
      @config = args[:config]
      self.logger = args[:logger] ||= HeirloomLogger.new
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      c = @config ? @config : YAML::load( File.open( config_file ) )

      aws = c['aws']

      self.access_key = aws['access_key']
      self.secret_key = aws['secret_key']
      self.regions = aws['regions']
      self.bucket_prefix = aws['bucket_prefix']
      self.authorized_aws_accounts = aws['authorized_aws_accounts']
      self.simpledb = aws['simpledb'] ||= true
      self.primary_region = regions ? regions.first : 'us-west-1'
    end

  end
end
