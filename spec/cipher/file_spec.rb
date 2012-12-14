require 'spec_helper'

describe Heirloom do
  before do
    @logger_mock = mock 'logger', :info => true
    @logger_mock.stub :info  => true,
                      :debug => true
    @config_mock = mock 'config'
    @config_mock.stub :logger => @logger_mock
    @tempfile_stub = stub 'tempfile', :path   => '/path_to_encrypted_archive', 
                                      :close! => true
    Tempfile.stub :new => @tempfile_stub
    @file = Heirloom::Cipher::File.new :config => @config_mock
  end

  it "should encrypt the given file" do
    @file.should_receive(:which).with('gpg').and_return true
    command = 'gpg --batch --yes -c --cipher-algo AES256 --passphrase mysecret --output /path_to_encrypted_archive /file 2>&1'
    @file.should_receive(:`).with command
    $?.stub :success? => true
    FileUtils.should_receive(:mv).
              with('/path_to_encrypted_archive', '/file')
    @file.encrypt_file(:file   => '/file',
                       :secret => 'mysecret').should be_true
  end

  it "should return false if gpg is not in the path" do
    @file.should_receive(:which).with('gpg').and_return false
    @logger_mock.should_receive(:error)
    @file.encrypt_file(:file   => '/file',
                       :secret => 'mysecret').should be_false
  end

  it "should return false if gpg returns non zero code" do
    @file.should_receive(:which).with('gpg').and_return true
    @logger_mock.should_receive(:error)
    command = 'gpg --batch --yes -c --cipher-algo AES256 --passphrase mysecret --output /path_to_encrypted_archive /file 2>&1'
    @file.should_receive(:`).with command
    $?.stub :success? => false
    @file.encrypt_file(:file   => '/file',
                       :secret => 'mysecret').should be_false
  end

end
