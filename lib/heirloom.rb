require "global_log"
require "global_config"

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

  extend self

  self.global_config_defaults = {
    :metadata_region => 'us-west-1',
    :log_level       => 'info',
    :logger          => self.log
  }
  self.global_config_file = "#{ENV['HOME']}/.heirloom.yml"

  def self.setup!
    self.log.info "hi!"
  end

end
