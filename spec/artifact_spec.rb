require 'spec_helper'

describe Heirloom do

  context "with an artifact object" do

    before do
      Heirloom::Config.should_receive(:new).and_return('config')
      @artifact = Heirloom::Artifact.new :logger => 'logger',
                                         :name   => 'tim',
                                         :id     => '123'
    end

    it "should build an artifact" do
      args = { :accounts => ['acct@test.com', 'acct2@test.com'],
               :directory => '.',
               :exclude => ['.git'],
               :git => true,
               :bucket_prefix => 'prefix',
               :public => true }
      @ab_mock = double('Artifact Builder Mock')
      Heirloom::ArtifactBuilder.should_receive(:new).
                                with(:config => 'config',
                                     :logger => 'logger',
                                     :name   => 'tim',
                                     :id     => '123').
                                and_return(@ab_mock)
      @ab_mock.should_receive(:build).with(@args)
      @artifact.build @args
    end

    it "should authorize an artifact" do
      args = { :public_readable => false }
      @aa_mock = double('Artifact Authorizer Mock')
      Heirloom::ArtifactAuthorizer.should_receive(:new).
                                   with(:config => 'config',
                                        :logger => 'logger',
                                        :name   => 'tim',
                                        :id     => '123').
                                   and_return(@aa_mock)
      @aa_mock.should_receive(:authorize).with(args)
      @artifact.authorize args
    end

  end

end
