require 'logging'

module GlobalLog

  def log
    @logger ||= Logging.logger(STDOUT)
  end

end
