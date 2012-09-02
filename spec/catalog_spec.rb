require 'spec_helper'

describe Heirloom::Catalog do

  before do 
    @config_mock = mock 'catalog'
    @regions     = ['us-west-1', 'us-west-2']
    @base        = 'thebase'
    @catalog     = Heirloom::Catalog.new :config => @config_mock,
                                         :name   => 'new_archive'
  end

  context "testing add" do
    it "should call setup to create catalog_domain" do
      @catalog_setup_mock = mock 'setup'
      Heirloom::Catalog::Setup.should_receive(:new).
                               with(:config => @config_mock).
                               and_return @catalog_setup_mock
      @catalog_setup_mock.should_receive(:create_catalog_domain).
                          and_return true
      @catalog.create_catalog_domain.should be_true
    end
  end

  context "testing setup" do
    it "should call setup to add_to_catalog" do
      @catalog_add_mock = mock 'add'
      Heirloom::Catalog::Add.should_receive(:new).
                             with(:config => @config_mock,
                                  :name   => 'new_archive').
                             and_return @catalog_add_mock
      @catalog_add_mock.should_receive(:add_to_catalog).
                        with(:base    => @base,
                             :regions => @regions).
                        and_return true
      @catalog.add_to_catalog(:base    => @base,
                              :regions => @regions).
               should be_true
    end
  end

  context "testing show" do
    before do
      @catalog_show_mock = mock 'show'
      Heirloom::Catalog::Show.should_receive(:new).
                              with(:config => @config_mock,
                                   :name   => 'new_archive').
                              and_return @catalog_show_mock
    end
    it "should call regions from show object" do
      @catalog_show_mock.should_receive(:regions).
                         and_return @regions
      @catalog.regions.should == @regions
    end

    it "should call base from the show object" do
      @catalog_show_mock.should_receive(:base).
                         and_return @base
      @catalog.base.should == @base
    end
  end

end
