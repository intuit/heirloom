require 'spec_helper'

describe Heirloom do

  it "should create a new logger object from the hash passed as :logger" do
    logger_mock = mock 'logger'
    logger_mock.should_receive(:info).with 'a message'
    logger_mock.should_receive(:level=).with Logger::INFO
    logger = Heirloom::HeirloomLogger.new :logger => logger_mock
    logger.info 'a message'
  end

  it "should create a new logger object when one is not passed" do
    logger_mock = mock 'logger'
    Logger.should_receive(:new).with(STDOUT).and_return logger_mock
    logger_mock.should_receive(:info).with 'a message'
    logger_mock.should_receive(:level=).with Logger::INFO
    logger = Heirloom::HeirloomLogger.new
    logger.info 'a message'
  end

  it "should set the log level to debug when passed in as log_level" do
    logger_mock = mock 'logger'
    Logger.should_receive(:new).with(STDOUT).and_return logger_mock
    logger_mock.should_receive(:level=).with Logger::DEBUG
    logger = Heirloom::HeirloomLogger.new :log_level => 'debug'
  end

end
