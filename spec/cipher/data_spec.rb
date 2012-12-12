require 'spec_helper'

describe Heirloom do
  before do
    @logger_mock = mock 'logger', :info => true
    @logger_mock.stub :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_mock
    @data = Heirloom::Cipher::Data.new :config => @config_mock
  end

  context "with secret given" do
    before do
      @aes_mock = mock 'aes'
      OpenSSL::Cipher::AES256.should_receive(:new).
                              with(:CBC).and_return @aes_mock
    end

    it "should decrypt the given data"

    it "should rescue bad key error and return false"

  end

  context "no secret given" do
    before do
      @data = Heirloom::Cipher::Data.new :config => @config_mock
    end

    it "should return the data if no secret given" do
      @data.decrypt_data(:data   => 'plaintext',
                         :secret => nil).should == 'plaintext'
    end
  end

end
