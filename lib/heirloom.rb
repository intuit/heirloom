require 'global_log.rb'
require 'global_config.rb'

require "heirloom/utils"

require "heirloom/acl"
require "heirloom/archive"
require "heirloom/aws"
require "heirloom/catalog"
require "heirloom/cipher"
require "heirloom/config"
require "heirloom/destroyer"
require "heirloom/directory"
require "heirloom/downloader"
require "heirloom/exceptions"
require "heirloom/logger"
require "heirloom/uploader"
require "heirloom/version"

module Heirloom
  
  include GlobalLog
  include GlobalConfig
  
  self.global_config_defaults = {
    :metadata_region => 'us-west-1',
    :level           => 'info',
    :logger          => self.log
  }
  self.global_config_file = "#{ENV['HOME']}/.heirloom.yml"

end

