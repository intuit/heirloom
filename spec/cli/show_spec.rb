require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @options = { :name            => 'archive_name',
                 :json            => true,
                 :id              => '1.0.0',
                 :level           => 'info',
                 :metadata_region => 'us-west-1' }
    @logger_stub = stub :debug => true
    @config_mock = mock_config(:logger => @logger_stub)
    @archive_mock = mock 'archive'
    Heirloom::HeirloomLogger.should_receive(:new).with(:log_level => 'info').
                             and_return @logger_stub
    Heirloom::CLI::Show.any_instance.should_receive(:load_config).
                        with(:logger => @logger_stub,
                             :opts   => @options).
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
    @archive_mock.stub :domain_exists? => true
  end

  context "returning base attributes" do
    before do
      @attributes = { 'id' => '1.0.0' }
    end

    context "as json" do
      before do
        @options[:json] = true
        Trollop.stub(:options).and_return @options
      end

      it "should show a given id as json" do
        @cli_show = Heirloom::CLI::Show.new
        @archive_mock.stub :show => @attributes
        @cli_show.should_receive(:jj).with @attributes
        @cli_show.show
      end
    end

    context "as human readable" do
      before do
        @options[:json] = false
        @options[:all] = true
        Trollop.stub(:options).and_return @options
      end

      it "should show a given id using the show formatter" do
        @cli_show = Heirloom::CLI::Show.new
        @archive_mock.stub :show => @attributes
        formatter_mock = mock 'format'
        Heirloom::CLI::Formatter::Show.stub :new => formatter_mock
        formatter_mock.should_receive(:format).
                       with(:attributes => @attributes,
                            :all        => true).
                       and_return 'the attribs'
        @cli_show.should_receive(:puts).with 'the attribs'
        @cli_show.show
      end
    end
  end
end
