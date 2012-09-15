require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @catalog = { 'test1' =>
                   { 'regions'       => ['us-west-1', 'us-east-1'],
                     'bucket_prefix' => ['bp1'] },
                 'test2' => 
                   { 'regions'       => ['us-west-2'],
                     'bucket_prefix' => ['bp2'] }
               } 
    @formatter = Heirloom::CLI::Formatter::Catalog.new
  end

  context "unfiltered" do
    context "with details" do
      it "should return the formated list" do
        format = "test1\n  Regions       : us-west-1, us-east-1\n  Bucket Prefix : bp1\ntest2\n  Regions       : us-west-2\n  Bucket Prefix : bp2"
        @formatter.format(:catalog => @catalog,
                          :details => true,
                          :name    => nil ).should == format
      end
    end
    context "without details" do
      it "should return the formated list" do
        @formatter.format(:catalog => @catalog,
                          :details => nil,
                          :name    => nil ).should == "test1\ntest2"
      end
    end
  end

  context "filtered" do
    context "with details" do
      it "should return the formated list" do
        format = "test1\n  Regions       : us-west-1, us-east-1\n  Bucket Prefix : bp1"
        @formatter.format(:catalog => @catalog,
                          :details => true,
                          :name    => 'test1').should == format
      end
    end
    context "without details" do
      it "should return the formated list" do
        @formatter.format(:catalog => @catalog,
                          :details => nil,
                          :name    => 'test1').should == 'test1'
      end
    end
  end

end
