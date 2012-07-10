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
             with("select * from test123 where built_at > '2000-01-01T00:00:00.000Z' \
                 order by built_at desc limit 10").
             and_return( {'1' => 'one', '2' => 'two', '3' => 'three'} )
    @lister.list.should == ['1', '2', '3']
  end

end
