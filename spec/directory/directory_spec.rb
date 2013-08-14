require 'spec_helper'

describe Heirloom::Directory do

  describe 'build_artifact_from_directory' do
    before do
      @config_mock = double 'config'
      @logger_stub = stub :debug => 'true', 
                          :info  => 'true', 
                          :warn  => 'true',
                          :error => 'true'
      @config_mock.stub(:logger).and_return(@logger_stub)
      @directory = Heirloom::Directory.new :config  => @config_mock,
                                           :exclude => ['dont_pack_me', 'dont_pack_me1'],
                                           :path    => '/dir',
                                           :file    => '/tmp/file.tar.gz'
    end

    context 'when succesful' do
      before do 
        @directory.should_receive(:which).with('tar').and_return true
        output_mock = double 'output mock'
        command = "cd /dir && tar czf /tmp/file.tar.gz --exclude dont_pack_me --exclude dont_pack_me1 ."
        files = ['pack_me', '.hidden', 'with a space', 'dont_pack_me', 'dont_pack_me1']
        Heirloom::Directory.any_instance.should_receive(:`).
                            with(command).
                            and_return output_mock
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
                       and_return true
          @directory.build_artifact_from_directory(:secret => 'supersecret').
                     should be_true
       end
      end
    end

    context 'when unable to create the tar' do
      before do 
        @directory.should_receive(:which).with('tar').and_return true
        output_mock = double 'output mock'
        command = "cd /dir && tar czf /tmp/file.tar.gz --exclude dont_pack_me --exclude dont_pack_me1 ."
        files = ['pack_me', '.hidden', 'with a space', 'dont_pack_me', 'dont_pack_me1']
        Heirloom::Directory.any_instance.should_receive(:`).
                            with(command).
                            and_return output_mock
        $?.stub(:success?).and_return(false)
      end

      it "build should return false" do
        @directory.build_artifact_from_directory(:secret => nil).should be_false
      end

      it "encrypted build should return false" do
        @directory.build_artifact_from_directory(:secret => 'supersecret').
                   should be_false
      end
    end

    context 'when required executable is missing' do
      before do
        files = ['pack_me', '.hidden', 'with a space', 'dont_pack_me', 'dont_pack_me1']
      end

      it "should return false if tar is not in path" do
        @directory.should_receive(:which).with('tar').and_return false
        @directory.build_artifact_from_directory(:secret => nil).should be_false
      end
    end

    context "parameter validation" do
      it "should not fail if exclude is nil" do
        @directory = Heirloom::Directory.new :config  => @config_mock,
                                             :exclude => nil,
                                             :path    => '/dir',
                                             :file    => '/tmp/file.tar.gz'
        @directory.stub(:`).and_return 'cmd output'
        lambda {
          @directory.build_artifact_from_directory(:exclude => nil)
        }.should_not raise_error
      end
    end

  end

end
