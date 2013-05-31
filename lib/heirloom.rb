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
  
  def self.log
    @logger ||= HeirloomLogger.new
  end
  
end

