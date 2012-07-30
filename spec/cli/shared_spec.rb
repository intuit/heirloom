require 'spec_helper'

require 'heirloom/cli/shared'

describe Heirloom do
  before do 
    @logger_mock = mock 'logger'
  end

  it "should return false if a required array is emtpy" do
    @logger_mock.should_receive(:error)
    Heirloom::CLI::Shared.valid_options?(:provided => { :array  => [],
                                                        :string => 'present' },
                                         :required => [:array, :string],
                                         :logger   => @logger_mock).
                          should be_false
  end

  it "should return false if a required string is nil" do
    @logger_mock.should_receive(:error)
    Heirloom::CLI::Shared.valid_options?(:provided => { :array  => ['present'],
                                                        :string => nil },
                                         :required => [:array, :string],
                                         :logger   => @logger_mock).
                          should be_false
  end

  it "shoudl return false if a require string is nil & array is empty" do
    @logger_mock.should_receive(:error).exactly(2).times
    Heirloom::CLI::Shared.valid_options?(:provided => { :array  => [],
                                                        :string => nil },
                                         :required => [:array, :string],
                                         :logger   => @logger_mock).
                          should be_false
  end

  it "shoudl return true if all options are present" do
    @logger_mock.should_receive(:error).exactly(0).times
    Heirloom::CLI::Shared.valid_options?(:provided => { :array  => ['present'],
                                                        :string => 'present' },
                                         :required => [:array, :string],
                                         :logger   => @logger_mock).
                          should be_true
  end
end
