require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @lister = Heirloom::ArtifactLister.new :config => @config_mock,
                                           :name     => 'test123'
  end

  it "should list the known artifacts" do
    sdb_mock = mock 'sdb'
    @lister.should_receive(:sdb).and_return sdb_mock
    sdb_mock.should_receive(:select).
             with("select * from test123").
             and_return( {'3' => 'three', '2' => 'two', '1' => 'one'} )
    @lister.list.should == ['1', '2', '3']
  end

end
