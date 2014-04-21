require 'spec_helper'

describe Heirloom::Catalog do

  before do
    @config_double = double 'catalog'
    @regions       = ['us-west-1', 'us-west-2']
    @bucket_prefix = 'bp'
    @catalog       = Heirloom::Catalog.new :config => @config_double, :name => 'new_archive'

    Heirloom.stub :log => double_log
  end

  context "cleanup" do
    before do
      @sdb = double 'sdb'
      @sdb.stub(:select)
        .and_yield('123', { 'preserve' => ['true'] })
        .and_yield('abc', { 'preserve' => ['true'] })
        .and_yield('456', { 'test' => ['banana'] })
    end

    it "should not destroy archives marked with 'preserve'" do

      archive = double 'archive', :destroy => true
      @catalog.stub :sdb => @sdb

      Heirloom::Archive.should_receive(:new)
        .with(hash_including(:id => '456'))
        .and_return archive

      @catalog.cleanup :num_to_keep => 10
    end

    it "should destroy archives when removed_preserved is true" do
      archive = double 'archive', :destroy => true
      @catalog.stub :sdb => @sdb

      Heirloom::Archive.should_receive(:new)
        .with(hash_including(:id => '123'))
        .and_return archive

      Heirloom::Archive.should_receive(:new)
        .with(hash_including(:id => 'abc'))
        .and_return archive

      Heirloom::Archive.should_receive(:new)
        .with(hash_including(:id => '456'))
        .and_return archive

      @catalog.cleanup :num_to_keep => 10, :remove_preserved => true
    end

  end

  context "testing add" do
    it "should call setup to create catalog_domain" do
      @catalog_setup_double = double 'setup'
      @catalog_setup_double.stub :create_catalog_domain => true
      Heirloom::Catalog::Setup.should_receive(:new).
                               with(:config => @config_double).
                               and_return @catalog_setup_double
      @catalog.create_catalog_domain.should be_true
    end
  end

  context "testing setup" do
    it "should call setup to add_to_catalog" do
      @catalog_add_double = double 'add'
      Heirloom::Catalog::Add.should_receive(:new).
                             with(:config => @config_double,
                                  :name   => 'new_archive').
                             and_return @catalog_add_double
      @catalog_add_double.should_receive(:add_to_catalog).
                          with(:bucket_prefix => @bucket_prefix,
                               :regions       => @regions).
                          and_return true
      @catalog.add_to_catalog(:bucket_prefix => @bucket_prefix,
                              :regions       => @regions).
               should be_true
    end
  end

  context "testing show" do
    before do
      @catalog_show_double = double 'show', :regions       => @regions,
                                        :bucket_prefix => @bucket_prefix
      Heirloom::Catalog::Show.should_receive(:new).
                              with(:config => @config_double,
                                   :name   => 'new_archive').
                              and_return @catalog_show_double
    end

    it "should call regions from show object" do
      @catalog.regions.should == @regions
    end

    it "should call bucket_prefix from the show object" do
      @catalog.bucket_prefix.should == @bucket_prefix
    end
  end

  context "testing catalog_domain_exists?" do
    before do
      @catalog_verify_double = double 'show'
      Heirloom::Catalog::Verify.should_receive(:new).
                                with(:config => @config_double).
                                and_return @catalog_verify_double
    end
    it "should return true if the catalog domain exists" do
      @catalog_verify_double.stub :catalog_domain_exists? => true
      @catalog.catalog_domain_exists?.should be_true
    end

    it "should return false if the catalog domain does not exist" do
      @catalog_verify_double.stub :catalog_domain_exists? => false
      @catalog.catalog_domain_exists?.should be_false
    end
  end

  context "testing entry_exists_in_catalog?" do
    before do
      @catalog_verify_double = double 'show'
      Heirloom::Catalog::Verify.should_receive(:new).
                                with(:config => @config_double).
                                and_return @catalog_verify_double
    end
    it "should return true if the entry exists in the catalog" do
      @catalog_verify_double.should_receive(:entry_exists_in_catalog?).
                             with('entry').
                             and_return true
      @catalog.entry_exists_in_catalog?('entry').should be_true
    end

    it "should return false if the entry does not exists in the catalog" do
      @catalog_verify_double.should_receive(:entry_exists_in_catalog?).
                             with('entry').
                             and_return false
      @catalog.entry_exists_in_catalog?('entry').should be_false
    end
  end

end
