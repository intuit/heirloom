require 'spec_helper'
require 'heirloom/cli'

describe Heirloom::CLI::Teardown do

  def stubbed_teardown
    teardown = Heirloom::CLI::Teardown.new
    teardown.stub(
      :ensure_domain_exists => true,
      :ensure_archive_domain_empty => true
    )
    teardown
  end

  before do
    Heirloom.stub :log => mock_log
    @config_mock = mock_config

    @defaults = { 
      :level           => 'info',
      :name            => 'archive_name',
      :metadata_region => 'us-west-1'
    }


    @archive_mock = mock 'archive'
    @archive_mock.stub(
      :delete_buckets => true,
      :delete_domain  => true
    )

    @catalog_mock = mock 'catalog'
    @catalog_mock.stub(
      :regions                  => ['us-west-1', 'us-west-2'],
      :bucket_prefix            => 'bp', 
      :catalog_domain_exists?   => true,
      :delete_from_catalog      => true,
      :entry_exists_in_catalog? => true
    )
    
    Trollop.stub :options => @defaults
    Heirloom::HeirloomLogger.stub :new => @logger_stub
    Heirloom::CLI::Teardown.any_instance.stub(:load_config)
      .and_return @config_mock
    Heirloom::Archive.stub :new => @archive_mock
    Heirloom::Catalog.stub :new => @catalog_mock
    @teardown = stubbed_teardown
  end

  context "delete existing archives force option" do
    
    it "should ask archive to delete when passed the 'force' option" do
      Trollop.stub :options => @defaults.merge(:force => true)
      @teardown = stubbed_teardown
      @catalog_mock.should_receive(:cleanup).with(
        :num_to_keep => 0,
        :remove_preserved => true
      )
      @teardown.teardown
    end

    it "should not ask archive to delete when not passed the 'force' option" do
      Trollop.stub :options => @defaults.merge(:force => nil)
      @teardown = stubbed_teardown
      @catalog_mock.should_not_receive(:cleanup)
      @teardown.teardown
    end
    
  end

  it "should delete s3 buckets, catalog and simpledb domain" do
    @teardown.should_receive(:ensure_domain_exists).with(
      :name   => 'archive_name',
      :config => @config_mock
    )
    @teardown.should_receive(:ensure_archive_domain_empty).with(
      :archive => @archive_mock,
      :config  => @config_mock
    )
    @archive_mock.should_receive(:delete_buckets)
    @archive_mock.should_receive(:delete_domain)
    @catalog_mock.should_receive(:delete_from_catalog)

    @teardown.teardown 
  end

end
