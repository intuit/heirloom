require 'spec_helper'

describe Heirloom::Directory do

  describe 'build_artifact_from_directory' do
    before do
      @config_mock = double 'config'
      @logger_stub = stub :debug => 'true', :info => 'true', :warn => 'true'
      @config_mock.stub(:logger).and_return(@logger_stub)
      @directory = Heirloom::Directory.new :config  => @config_mock,
                                           :exclude => ['.', '..', 'dont_pack_me'],
                                           :path    => '/dir'
      @tempfile_stub = stub 'tempfile', :path => '/tmp/file.tar.gz'
      Tempfile.stub :new => @tempfile_stub
      output_mock  = double 'output mock'
      Dir.should_receive(:entries).with('/dir').
                                   exactly(2).times.
                                   and_return(['pack_me', '.hidden', 'dont_pack_me'])
      Heirloom::Directory.any_instance.should_receive(:`).
                          with("cd /dir && tar czf /tmp/file.tar.gz pack_me .hidden").
                          and_return output_mock
    end

    context 'when succesful' do
      before do 
        $?.stub :success? => true
      end

      context 'without secret provided' do
        it "should build an archive from the path" do
          @directory.build_artifact_from_directory(:secret => nil).
                     should be_true
        end
      end

      context 'without secret provided' do
        before do
          @cipher_mock = mock 'cipher'
          Heirloom::Cipher::File.should_receive(:new).
                                 with(:config => @config_mock).
                                 and_return @cipher_mock
        end

        it "should build and encrypt an archive from the path" do
          @cipher_mock.should_receive(:encrypt_file).
                       with(:file => '/tmp/file.tar.gz', 
                            :secret => 'supersecret').
                       and_return '/tmp/encrypted_file.tar.gz'
          @directory.build_artifact_from_directory(:secret => 'supersecret').
                     should be_true
       end
      end
    end

    context 'when unable to create the tar' do
      before { $?.stub(:success?).and_return(false) }

      it "build should return false" do
        @directory.build_artifact_from_directory(:secret => nil).should be_false
      end

      it "encrypted build should return false" do
        @directory.build_artifact_from_directory(:secret => 'supersecret').
                   should be_false
      end
    end

  end

end
