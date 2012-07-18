require 'spec_helper'

describe Heirloom do

    before do
      Heirloom::Config.should_receive(:new).and_return('config')
      @heirloom = Heirloom::Archive.new :logger => 'logger',
                                        :name   => 'tim',
                                        :id     => '123'
    end


    context "test public methods" do
      before do
        @mock = double('Mock')
      end

      it "should call build method with given args" do
        @heirloom.should_receive(:builder).and_return(@mock)
        @mock.should_receive(:build).with('args')
        @heirloom.build('args')
      end

      it "should call download method with given args" do
        @heirloom.should_receive(:downloader).and_return(@mock)
        @mock.should_receive(:download).with('args')
        @heirloom.download('args')
      end

      it "should call update heirloom method with given args" do
        @heirloom.should_receive(:updater).and_return(@mock)
        @mock.should_receive(:update).with('args')
        @heirloom.update('args')
      end

      it "should call upload heirloom method with given args" do
        @heirloom.should_receive(:uploader).and_return(@mock)
        @mock.should_receive(:upload).with('args')
        @heirloom.upload('args')
      end

      it "should call authorize method" do
        @heirloom.should_receive(:authorizer).and_return(@mock)
        @mock.should_receive(:authorize)
        @heirloom.authorize
      end

      it "should call heirloom exists method" do
        @heirloom.should_receive(:reader).and_return(@mock)
        @mock.should_receive(:exists?)
        @heirloom.exists?
      end

      it "should call show method" do
        @heirloom.should_receive(:reader).and_return(@mock)
        @mock.should_receive(:show)
        @heirloom.show
      end

      it "should call list method" do
        @heirloom.should_receive(:lister).and_return(@mock)
        @mock.should_receive(:list)
        @heirloom.list
      end

      it "should call cleanup method" do
        @heirloom.should_receive(:builder).and_return(@mock)
        @mock.should_receive(:cleanup)
        @heirloom.cleanup
      end

    end

end
