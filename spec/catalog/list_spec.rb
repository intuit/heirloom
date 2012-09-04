require 'spec_helper'

describe Heirloom::Catalog::List do

  before do
    @config_stub = stub 'config'
    @sdb_mock = mock 'sdb'
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_stub).
                            and_return @sdb_mock
    @list = Heirloom::Catalog::List.new :config => @config_stub
  end

  it "should list all heirlooms in the catalog" do
    @sdb_mock.should_receive(:select).
              with("SELECT * FROM heirloom").
              and_return 'result'
    @list.all.should == 'result'
  end

end
