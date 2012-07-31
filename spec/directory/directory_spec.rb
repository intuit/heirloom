require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @logger_mock = double 'logger'
      @config_mock.should_receive(:logger).and_return(@logger_mock)
      @directory = Heirloom::Directory.new :config  => @config_mock,
                                           :exclude => ['.', '..', 'dont_pack_me'],
                                           :path    => '/target/dir'
    end

    it "should build an archive from the latest commit in path" do
      @logger_mock.should_receive(:info).exactly(4).times
      @logger_mock.should_receive(:debug)
      file_mock = double 'file'
      output_mock = double 'output mock'
      File.should_receive(:join).and_return 'tar_file'
      Dir.should_receive(:entries).with('/target/dir').
                                   exactly(2).times.
                                   and_return(['pack_me', '.hidden', 'dont_pack_me'])
      Heirloom::Directory.any_instance.should_receive(:`).
                          with("tar czpf tar_file pack_me .hidden").
                          and_return output_mock
      $?.should_receive(:success?).and_return true
      @directory.build_artifact_from_directory.should be_true
    end

    it "should return false if the shell is not succesful" do
      @logger_mock.should_receive(:info).exactly(4).times
      @logger_mock.should_receive(:debug)
      file_mock = double 'file'
      output_mock = double 'output mock'
      File.should_receive(:join).and_return 'tar_file'
      Dir.should_receive(:entries).with('/target/dir').
                                   exactly(2).times.
                                   and_return(['pack_me', '.hidden', 'dont_pack_me'])
      Heirloom::Directory.any_instance.should_receive(:`).
                          with("tar czpf tar_file pack_me .hidden").
                          and_return output_mock
      $?.should_receive(:success?).and_return false
      @directory.build_artifact_from_directory.should be_false
    end

end
