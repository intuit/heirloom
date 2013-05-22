require 'spec_helper'

describe Heirloom::GlobalConfig do

  class DummyClass
  end

  before do
    @dummy = DummyClass.new
    @dummy.extend(Heirloom::GlobalConfig)
  end

  it "should have a config hash" do
    @dummy.config.should be_kind_of Hash
  end

  it "should be able to be configured" do
    @dummy.load_config! :mysql_password => 'banana'
    @dummy.config.mysql_password.should == 'banana'
  end

  it "should be able to set defaults" do
    @dummy.config_defaults = { :host => 'localhost' }
    @dummy.config.host.should == 'localhost'
  end

  it "should be able to override defaults" do
    @dummy.config_defaults = { :host => 'localhost' }
    @dummy.load_config! 'host' => 'dev.example.com'
    @dummy.config.host.should == 'dev.example.com'
  end

end
