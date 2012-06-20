require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @config_mock.should_receive(:logger).and_return(@logger_mock)
    @reader = Heirloom::ArtifactUpdater.new :config => @config_mock,
                                            :name   => 'tim',
                                            :id     => '123'
  end

  it "should test the artifact updater methods"

end
