require 'spec_helper'

describe Heirloom do

  it "should create a new logger object from the hash passed as :logger" do
    logger_mock = mock 'logger'
    logger_mock.should_receive(:info).with 'a message'
    logger = Heirloom::HeirloomLogger.new :logger => logger_mock
    logger.info 'a message'
  end

  it "should create a new logger object when one is not passed" do
    logger_mock = mock 'logger'
    Logger.should_receive(:new).with($stdout).and_return logger_mock
    logger_mock.should_receive(:info).with 'a message'
    logger_mock.should_receive(:datetime_format=).with '%Y-%m-%dT%H:%M:%S%z'
    logger_mock.should_receive(:formatter=)
    logger_mock.should_receive(:level=).with 1
    logger = Heirloom::HeirloomLogger.new
    logger.info 'a message'
  end

end
