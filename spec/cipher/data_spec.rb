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

    it "should decrypt the given data" do
      @aes_mock.should_receive(:decrypt)
      @aes_mock.should_receive(:key=).with 'mysecret'
      @aes_mock.should_receive(:iv=).with 'firstsixteenchar'
      @aes_mock.should_receive(:update).with('crypteddata').and_return 'cleartext'
      @aes_mock.should_receive(:final).and_return 'final'
      @data.decrypt_data(:data => 'firstsixteencharcrypteddata',
                         :secret => 'mysecret').
            should == 'cleartextfinal'
    end

    it "should rescue bad key error and return false" do
      @logger_mock.should_receive(:error).with "Unable to decrypt archive."
      @aes_mock.should_receive(:decrypt)
      @aes_mock.should_receive(:key=).with 'badsecret'
      @aes_mock.should_receive(:iv=).with 'firstsixteenchar'
      @aes_mock.should_receive(:update).with('crypteddata').and_return 'crap'
      @aes_mock.should_receive(:final).and_raise OpenSSL::Cipher::CipherError
      @data.decrypt_data(:data => 'firstsixteencharcrypteddata',
                         :secret => 'badsecret').
            should be_false
    end

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
