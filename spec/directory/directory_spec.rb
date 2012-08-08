require 'spec_helper'

describe Heirloom::Directory do

  describe 'build_artifact_from_directory' do
    before do
      @config_mock = double 'config'
      @logger_stub = stub :debug => 'true', :info => 'true', :warn => 'true'
      @config_mock.stub(:logger).and_return(@logger_stub)
      @directory = Heirloom::Directory.new :config  => @config_mock,
                                           :exclude => ['.', '..', 'dont_pack_me'],
                                           :path    => '/target/dir'
      output_mock  = double 'output mock'
      Dir.stub :tmpdir => '/tmp/dir'
      Kernel.stub :rand => 0
      Dir.should_receive(:entries).with('/target/dir').
                                   exactly(2).times.
                                   and_return(['pack_me', '.hidden', 'dont_pack_me'])
      Heirloom::Directory.any_instance.should_receive(:`).
                          with("tar czf /tmp/dir/AAAAAAAA.tar.gz pack_me .hidden").
                          and_return output_mock
    end

    it "should build an archive from the latest commit in path" do
      $?.should_receive(:success?).and_return true
      @directory.build_artifact_from_directory.should be_true
    end

    context 'when unable to create the tar' do
      before { $?.stub(:success?).and_return(false) }

      it { @directory.build_artifact_from_directory.should be_false }
    end

  end

end
