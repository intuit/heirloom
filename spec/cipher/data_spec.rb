require 'spec_helper'

describe Heirloom do
  before do
    @encrypted_file_double = double 'encrypted mock'
    @decrypted_file_double = double 'decrypted mock'
    @encrypted_file_double.stub :path => '/tmp/enc'
    @decrypted_file_double.stub :path => '/tmp/dec',
                                :read => 'plaintext'
    @logger_double = double 'logger', :info => true
    @logger_double.stub :info  => true,
                        :debug => true
    @config_double = double 'config'
    @config_double.stub :logger => @logger_double
    @data = Heirloom::Cipher::Data.new :config => @config_double
  end

  context "when succesful" do
    context "with secret given" do
      it "should decrypt the given data" do
        @data.should_receive(:which).with('gpg').and_return true
        Tempfile.should_receive(:new).with('archive.tar.gz.gpg').
                 and_return @encrypted_file_double
        Tempfile.should_receive(:new).with('archive.tar.gz').
                 and_return @decrypted_file_double
        ::File.should_receive(:open).
               with(@encrypted_file_double,'w')
        $?.stub :success? => true

        command = 'gpg --batch --yes --cipher-algo AES256 --passphrase password --output /tmp/dec /tmp/enc 2>&1'
        @data.should_receive(:`).with(command).and_return true
        @data.decrypt_data(:data   => 'crypted',
                           :secret => 'password').should == 'plaintext'
      end
    end

    context "no secret given" do
      it "should return the data if no secret given" do
        @data.decrypt_data(:data   => 'plaintext',
                           :secret => nil).should == 'plaintext'
      end
    end
  end

  context "when unsuccesful" do
    context "with secret given" do
      it "should return false if gpg not in path" do
        @logger_double.should_receive(:error)
        @data.should_receive(:which).with('gpg').and_return false
        @data.decrypt_data(:data   => 'crypted',
                           :secret => 'password').should be_false
      end

      it "should return false if decrypted fails" do
        @logger_double.should_receive(:error)
        @data.should_receive(:which).with('gpg').and_return true
        Tempfile.should_receive(:new).with('archive.tar.gz.gpg').
                 and_return @encrypted_file_double
        Tempfile.should_receive(:new).with('archive.tar.gz').
                 and_return @decrypted_file_double
        ::File.should_receive(:open).
               with(@encrypted_file_double,'w')
        $?.stub :success? => false

        command = 'gpg --batch --yes --cipher-algo AES256 --passphrase password --output /tmp/dec /tmp/enc 2>&1'
        @data.should_receive(:`).with(command).and_return true
        @data.decrypt_data(:data   => 'crypted',
                           :secret => 'password').should be_false
      end
    end
  end

end
