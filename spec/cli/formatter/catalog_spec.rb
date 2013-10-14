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
    it "should return the formated list" do
      @formatter.format(:catalog => @catalog,
                        :details => nil,
                        :region => nil,
                        :name    => nil ).should == "test1\ntest2"
    end
  end

  context "filtered" do
    it "should return the name with details" do
      format = "test1\n" +
               "  regions          : us-west-1, us-east-1\n" +
               "  bucket_prefix    : bp1\n" +
               "  us-west-1-s3-url : s3://bp1-us-west-1/test1\n" +
               "  us-east-1-s3-url : s3://bp1-us-east-1/test1"
      @formatter.format(:catalog => @catalog,
                        :name    => 'test1').should == format
    end

    it "should return not found if name does not exist in catalog" do
      format = "Heirloom not_here not found in catalog."
      @formatter.format(:catalog => @catalog,
                        :name    => 'not_here').should == format
    end
  end

end
