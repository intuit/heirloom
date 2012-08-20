require 'spec_helper'

describe Heirloom do
  before do
    @logger_mock = mock 'logger', :info => true
    @logger_mock.stub :info => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_mock
    @tempfile_stub = stub 'tempfile', :path => '/path_to_encrypted_archive'
    Tempfile.stub :new => @tempfile_stub
    @aes_mock = mock 'aes'
    @aes_mock.stub :random_iv => 'firstsixteenchar'
    OpenSSL::Cipher::AES256.should_receive(:new).
                            with(:CBC).and_return @aes_mock
    @file = Heirloom::Cipher::File.new :config => @config_mock
  end

  it "should encrypt the given file" do
    @aes_mock.should_receive(:encrypt)
    @aes_mock.should_receive(:iv=).with 'firstsixteenchar'
    @aes_mock.should_receive(:key=).with Digest::SHA256.hexdigest 'mysecret'
    ::File.should_receive(:open)
    @file.encrypt_file(:file   => '/file',
                       :secret => 'mysecret').
          should == '/path_to_encrypted_archive'
  end

end
