require 'spec_helper'

describe Heirloom::Catalog::Show do

  before do
    @config_double = double 'config'
    @sdb_double = double 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_double).
                            and_return @sdb_double
    @show = Heirloom::Catalog::Show.new :config => @config_double,
                                        :name   => 'a_archive'
  end

  it "should return the bucket_prefix" do
    result = { 'heirloom_a_archive' =>
               { 'bucket_prefix' => [ 'bp' ] }
             }
    @sdb_double.should_receive(:select).
                with("select bucket_prefix from heirloom where itemName() = 'heirloom_a_archive'").
                and_return result
    @show.bucket_prefix.should == 'bp'
  end

  it "should return the regions" do
    regions = ['us-west-1', 'us-west-2']
    result = { 'heirloom_a_archive' => { 'regions' => @regions } }
    @sdb_double.should_receive(:select).
                with("select regions from heirloom where itemName() = 'heirloom_a_archive'").
                and_return result
    @show.regions.should == @regions
  end

end
