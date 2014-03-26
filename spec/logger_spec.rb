require 'spec_helper'

describe Heirloom do

  it "should create a new logger object from the hash passed as :logger" do
    logger_double = double 'logger'
    logger_double.should_receive(:info).with 'a message'
    logger = Heirloom::HeirloomLogger.new :logger => logger_double
    logger.info 'a message'
  end

  it "should create a new logger object when one is not passed" do
    logger_double = double 'logger'
    Logger.should_receive(:new).with($stdout).and_return logger_double
    logger_double.should_receive(:info).with 'a message'
    logger_double.should_receive(:datetime_format=).with '%Y-%m-%dT%H:%M:%S%z'
    logger_double.should_receive(:formatter=)
    logger_double.should_receive(:level=).with 1
    logger = Heirloom::HeirloomLogger.new
    logger.info 'a message'
  end

end
