require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do

    options = { :name          => 'archive_name',
                :id            => '1.0.0',
                :bucket_prefix => 'bp',
                :old_secret    => 'oldpassword',
                :new_secret    => 'newpassword' }
    Trollop.stub(:options).and_return options

    catalog_stub = stub :regions => ['us-east-1', 'us-west-1']
    Heirloom::Catalog.stub(:new).and_return(catalog_stub)

  end

  it "should delegate to archive object" do

    Heirloom::Archive.stub(:new).and_return(@archive_mock)

    @archive_mock.should_receive(:rotate)

    @cli_rotate = Heirloom::CLI::Rotate.new.rotate

  end
  
end
