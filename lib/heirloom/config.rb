module Heirloom
  class Config

    attr_accessor :access_key, :secret_key, :regions, 
                  :primary_region, :bucket_prefix, :authorized_aws_accounts

    def initialize(args = {})
      @config = args[:config]
      load_config_file
    end

    def load_config_file
      config_file = "#{ENV['HOME']}/.heirloom.yml"
      c = @config ? @config : YAML::load( File.open( config_file ) )

      self.access_key = c['aws']['access_key']
      self.secret_key = c['aws']['secret_key']
      self.regions = c['aws']['regions']
      self.primary_region = regions.first
      self.bucket_prefix = c['aws']['bucket_prefix']
      self.authorized_aws_accounts = c['aws']['authorized_aws_accounts']
    end

  end
end
