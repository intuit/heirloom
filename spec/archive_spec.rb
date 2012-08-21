require 'spec_helper'

describe Heirloom do

  before do
    @config_mock = mock 'config'
    @archive = Heirloom::Archive.new :config => @config_mock,
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
      reader_mock = double('reader mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_mock
      reader_mock.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Uploader.should_receive(:new).
                         with(:config => @config_mock,
                              :name   => 'chef',
                              :id     => '123').
                         and_return mock
      mock.should_receive(:upload).with('arg' => 'val', :regions => ['us-west-1', 'us-west-2'])
      @archive.upload('arg' => 'val')
    end

    it "should call authorize method" do
      mock = double('Mock')
      reader_mock = double('reader mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_mock
      reader_mock.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Authorizer.should_receive(:new).
                           with(:config => @config_mock,
                                :name   => 'chef',
                                :id     => '123').
                           and_return mock
      mock.should_receive(:authorize).with :regions  => ['us-west-1', 'us-west-2'],
                                           :accounts => ['acct1', 'acct2']
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
      destroyer_mock = double('destroyer mock')
      reader_mock = double('reader mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_mock
      reader_mock.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Destroyer.should_receive(:new).
                          with(:config  => @config_mock,
                               :name    => 'chef',
                               :id      => '123').
                          and_return destroyer_mock
      destroyer_mock.should_receive(:destroy).
                     with(:regions => ['us-west-1', 'us-west-2'])
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

    it "should call the count method for an archive" do
      mock = double('Mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_mock,
                               :name   => 'chef',
                               :id     => '123').
                          and_return mock
      mock.should_receive(:count)
      @archive.count
    end
  end
end
