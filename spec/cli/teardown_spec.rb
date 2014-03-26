require 'spec_helper'
require 'heirloom/cli'

describe Heirloom::CLI::Teardown do

  def doublebed_teardown
    teardown = Heirloom::CLI::Teardown.new
    teardown.stub(
      :ensure_domain_exists => true,
      :ensure_archive_domain_empty => true
    )
    teardown
  end

  before do
    Heirloom.stub :log => double_log
    @config_double = double_config

    @defaults = {
      :level           => 'info',
      :name            => 'archive_name',
      :metadata_region => 'us-west-1'
    }


    @archive_double = double 'archive'
    @archive_double.stub(
      :delete_buckets => true,
      :delete_domain  => true
    )

    @catalog_double = double 'catalog'
    @catalog_double.stub(
      :regions                  => ['us-west-1', 'us-west-2'],
      :bucket_prefix            => 'bp',
      :catalog_domain_exists?   => true,
      :delete_from_catalog      => true,
      :entry_exists_in_catalog? => true
    )

    Trollop.stub :options => @defaults
    Heirloom::HeirloomLogger.stub :new => @logger_double
    Heirloom::CLI::Teardown.any_instance.stub(:load_config)
      .and_return @config_double
    Heirloom::Archive.stub :new => @archive_double
    Heirloom::Catalog.stub :new => @catalog_double
    @teardown = doublebed_teardown
  end

  context "delete existing archives force option" do

    it "should ask archive to delete when passed the 'force' option" do
      Trollop.stub :options => @defaults.merge(:force => true)
      @teardown = doublebed_teardown
      @catalog_double.should_receive(:cleanup).with(
        :num_to_keep => 0,
        :remove_preserved => true
      )
      @teardown.teardown
    end

    it "should not ask archive to delete when not passed the 'force' option" do
      Trollop.stub :options => @defaults.merge(:force => nil)
      @teardown = doublebed_teardown
      @catalog_double.should_not_receive(:cleanup)
      @teardown.teardown
    end

  end

  it "should delete s3 buckets, catalog and simpledb domain" do
    @teardown.should_receive(:ensure_domain_exists).
              with(:name   => 'archive_name',
                   :config => @config_double)
    @teardown.should_receive(:ensure_archive_domain_empty).
              with(:archive => @archive_double,
                   :config  => @config_double)
    @archive_double.should_receive(:delete_buckets)
    @archive_double.should_receive(:delete_domain)
    @catalog_double.should_receive(:delete_from_catalog)
    @teardown.teardown
  end

end
