require 'spec_helper'

describe Heirloom do

  it "should create a new config object" do
    config = Heirloom::Config.new
    config.class.should == Heirloom::Config
  end

end

