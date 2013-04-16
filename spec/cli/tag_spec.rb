require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    options = { :name            => 'archive_name',
                :id              => '1.0.0',
                :level           => 'info',
                :attribute       => 'att',
                :value           => 'val',
                :metadata_region => 'us-west-1' }
    @logger_stub = stub :debug => true, :error => true
    @config_mock = mock_config(:logger => @logger_stub)
    @archive_mock = mock 'archive'
    
    Trollop.stub(:options).and_return options
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Tag.any_instance.should_receive(:load_config).
                       with(:logger => @logger_stub,
                            :opts   => options).
                       and_return @config_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name => 'archive_name',
                           :config => @config_mock).
                      and_return @archive_mock
    Heirloom::Archive.should_receive(:new).
                      with(:name   => 'archive_name',
                           :id     => '1.0.0',
                           :config => @config_mock).
                      and_return @archive_mock
    @archive_mock.stub :exists? => true
    @archive_mock.should_receive(:domain_exists?).and_return true
    @cli_tag = Heirloom::CLI::Tag.new
  end

  it "should tag an archive attribute with a given id" do
    @archive_mock.stub :exists? => true
    @archive_mock.should_receive(:update).
                  with(:attribute => 'att',
                       :value     => 'val')
    @cli_tag.tag
  end

  it "should exit if the archive does not exist" do
    @archive_mock.stub :exists? => false
    lambda { @cli_tag.tag }.should raise_error SystemExit
  end

end
