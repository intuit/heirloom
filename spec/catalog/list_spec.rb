require 'spec_helper'

describe Heirloom::Catalog::List do

  before do
    @config_double = double 'config'
    @sdb_double = double 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_double).
                            and_return @sdb_double
    @list = Heirloom::Catalog::List.new :config => @config_double
  end

  it "should list all heirlooms in the catalog" do
    @sdb_double.should_receive(:select).
                with("SELECT * FROM heirloom").
                and_return 'result'
    @list.all.should == 'result'
  end

end
