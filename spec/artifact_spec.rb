require 'spec_helper'

describe Heirloom do

    before do
      Heirloom::Config.should_receive(:new).and_return('config')
      @artifact = Heirloom::Artifact.new :logger => 'logger',
                                         :name   => 'tim',
                                         :id     => '123'
    end


    context "test public methods" do
      before do
        @mock = double('Mock')
      end

      it "should call build method with given args" do
        @artifact.should_receive(:builder).and_return(@mock)
        @mock.should_receive(:build).with('args')
        @artifact.build('args')
      end

      it "should call download method with given args" do
        @artifact.should_receive(:downloader).and_return(@mock)
        @mock.should_receive(:download).with('args')
        @artifact.download('args')
      end

      it "should call update artifact method with given args" do
        @artifact.should_receive(:updater).and_return(@mock)
        @mock.should_receive(:update).with('args')
        @artifact.update('args')
      end

      it "should call upload artifact method with given args" do
        @artifact.should_receive(:uploader).and_return(@mock)
        @mock.should_receive(:upload).with('args')
        @artifact.upload('args')
      end

      it "should call authorize method" do
        @artifact.should_receive(:authorizer).and_return(@mock)
        @mock.should_receive(:authorize)
        @artifact.authorize
      end

      it "should call artifact exists method" do
        @artifact.should_receive(:reader).and_return(@mock)
        @mock.should_receive(:exists?)
        @artifact.exists?
      end

      it "should call show method" do
        @artifact.should_receive(:reader).and_return(@mock)
        @mock.should_receive(:show)
        @artifact.show
      end

      it "should call list method" do
        @artifact.should_receive(:lister).and_return(@mock)
        @mock.should_receive(:list)
        @artifact.list
      end

      it "should call cleanup method" do
        @artifact.should_receive(:builder).and_return(@mock)
        @mock.should_receive(:cleanup)
        @artifact.cleanup
      end

    end

end
