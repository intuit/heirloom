require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = double 'config'
    @logger_mock = double 'logger'
    @config_mock.should_receive(:logger).and_return(@logger_mock)
    @updater = Heirloom::Updater.new :config => @config_mock,
                                     :name   => 'tim',
                                     :id     => '123'
  end

  it "should test an attribute is updated" do
    sdb_mock = mock 'sdb mock'
    @logger_mock.should_receive(:info)
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_mock).
                            and_return sdb_mock
    sdb_mock.should_receive(:put_attributes).
             with('heirloom_tim', '123', { 'attr' => 'val' }, { :replace => 'attr' })
    @updater.update :attribute => 'attr',
                    :value     => 'val'
  end

end
