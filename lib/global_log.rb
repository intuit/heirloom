require 'logging'

module GlobalLog

  def self.included(base)
    base.extend(self)
  end
  
  def log
    @logger ||= Logging.logger($stdout)
  end

end
