require 'spec_helper'

describe Heirloom do

  before do
      @config_mock = mock 'config'
      @logger_mock = mock 'logger'
      Heirloom::Config.should_receive(:new).and_return @config_mock
      @archive = Heirloom::Archive.new :logger => @logger_mock,
                                       :name   => 'chef',
                                       :id     => '123'
  end


  context "test public methods" do

    it "should call build with given args" do
      mock = double('Mock')
      Heirloom::Builder.should_receive(:new).
                        with(:config => @config_mock,
                             :name   => 'chef',
                             :id     => '123').
                        and_return mock
      mock.should_receive(:build).with('args')
      @archive.build('args')
    end

    it "should call download method with given args" do
      mock = double('Mock')
      Heirloom::Downloader.should_receive(:new).
                           with(:config => @config_mock,
                                :name   => 'chef',
                                :id     => '123').
                           and_return mock
      mock.should_receive(:download).with('args')
      @archive.download('args')
    end

    it "should call update archive method with given args" do
      mock = double('Mock')
      Heirloom::Updater.should_receive(:new).
                        with(:config => @config_mock,
                             :name   => 'chef',
                             :id     => '123').
                        and_return mock
      mock.should_receive(:update).with('args')
      @archive.update('args')
    end

    it "should call upload archive method with given args" do
      mock = double('Mock')
      Heirloom::Uploader.should_receive(:new).
                         with(:config => @config_mock,
                              :name   => 'chef',
                              :id     => '123').
                         and_return mock
      mock.should_receive(:upload).with('args')
      @archive.upload('args')
    end

    it "should call authorize method" do
      mock = double('Mock')
      Heirloom::Authorizer.should_receive(:new).
                           with(:config => @config_mock,
                                :name   => 'chef',
                                :id     => '123').
                           and_return mock
      mock.should_receive(:authorize).with ['acct1', 'acct2']
      @archive.authorize ['acct1', 'acct2']
    end

    it "should call archive exists method and return true if archive exists" do
      mock = double('Mock')
      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_mock,
                                 :name   => 'chef',
                                 :id     => '123').
                            and_return mock
      mock.should_receive(:exists?).and_return true
      @archive.exists?.should be_true
    end

    it "should call archive exists method and return fasle if archive doesnt exists" do
      mock = double('Mock')
      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_mock,
                            :name   => 'chef',
                            :id     => '123').
                       and_return mock
      mock.should_receive(:exists?).and_return false
      @archive.exists?.should be_false
    end

    it "should call show method" do
      mock = double('Mock')
      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_mock,
                            :name   => 'chef',
                            :id     => '123').
                       and_return mock
      mock.should_receive(:show)
      @archive.show
    end

    it "should call list method" do
      mock = double('Mock')
      Heirloom::Lister.should_receive(:new).
                       with(:config => @config_mock,
                            :name   => 'chef').
                       and_return mock
      mock.should_receive(:list)
      @archive.list
    end

    it "should call cleanup method" do
      mock = double('Mock')
      Heirloom::Builder.should_receive(:new).
                        with(:config => @config_mock,
                             :name   => 'chef',
                             :id     => '123').
                        and_return mock
      mock.should_receive(:cleanup)
      @archive.cleanup
    end

    it "should return true if the required buckets exist" do
      mock = double('Mock')
      Heirloom::Verifier.should_receive(:new).
                         with(:config => @config_mock,
                              :name   => 'chef').
                         and_return mock
      mock.should_receive(:buckets_exist?).
           with(:bucket_prefix => 'test-123').and_return true
      @archive.buckets_exist?(:bucket_prefix => 'test-123').
               should be_true
    end

    it "should return false if the required buckets don't exist" do
      mock = double('Mock')
      Heirloom::Verifier.should_receive(:new).
                         with(:config => @config_mock,
                              :name   => 'chef').
                         and_return mock
      mock.should_receive(:buckets_exist?).
           with(:bucket_prefix => 'test-123').and_return false
      @archive.buckets_exist?(:bucket_prefix => 'test-123').
               should be_false
    end

    it "should call the destroy method" do
      mock = double('Mock')
      Heirloom::Destroyer.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return mock
      mock.should_receive(:destroy)
      @archive.destroy
    end

    it "should call the regions method for an archive" do
      mock = double('Mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return mock
      mock.should_receive(:regions)
      @archive.regions
    end
  end
end
