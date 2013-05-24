require "heirloom/global_config"
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
  
  # include Log
  include GlobalConfig

  def self.log
    @logger ||= HeirloomLogger.new
  end
  
end

