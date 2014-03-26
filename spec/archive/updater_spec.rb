require 'spec_helper'

describe Heirloom do

  before do
    @config_double = double 'config'
    @logger_double = double 'logger'
    @config_double.should_receive(:logger).and_return(@logger_double)
    @updater = Heirloom::Updater.new :config => @config_double,
                                     :name   => 'tim',
                                     :id     => '123'
  end

  it "should test an attribute is updated" do
    sdb_double = double 'sdb mock'
    @logger_double.should_receive(:info)
    Heirloom::AWS::SimpleDB.should_receive(:new).
                            with(:config => @config_double).
                            and_return sdb_double
    sdb_double.should_receive(:put_attributes).
             with('heirloom_tim', '123', { 'attr' => 'val' }, { :replace => 'attr' })
    @updater.update :attribute => 'attr',
                    :value     => 'val'
  end

end
