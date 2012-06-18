require 'spec_helper'

describe Heirloom do
  before do
    @config = { 'access_key'              => 'key',
                'secret_key'              => 'secret',
                'regions'                 => ['us-west-1', 'us-west-2'],
                'bucket_prefix'           => 'prefix',
                'authorized_aws_accounts' => [ 'test1 @acct.com', 'test2@acct.com' ] }
    @logger = 'logger'
  end

  it "should create a new artifact object" do
    Heirloom::Config.should_receive(:new).with(:config => @config)
    Heirloom::HeirloomLogger.should_receive(:new).with(:logger => 'logger')
    artifact = Heirloom::Artifact.new :config => @config,
                                      :logger => 'logger'
  end

  it "should build the artifact"

  it "should update the artifact"

end
