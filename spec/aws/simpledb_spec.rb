require 'spec_helper'

describe Heirloom::AWS::SimpleDB do

  before do
    @sdb = Heirloom::AWS::SimpleDB.new :config => mock_config
  end

  context "credential management" do

    it "should use the access and secret keys by default" do

      config = mock_config(
        :aws_access_key_id => 'key',
        :aws_secret_access_key => 'secret'
      )

      Fog::AWS::SimpleDB.should_receive(:new).with(
        :aws_access_key_id => 'key',
        :aws_secret_access_key => 'secret',
        :region => 'us-west-1'
      )

      s3 = Heirloom::AWS::SimpleDB.new :config => config

    end

    it "should use the iam role if asked to" do

      config = mock_config :use_iam_profile => true
      
      Fog::AWS::SimpleDB.should_receive(:new).with(
        :use_iam_profile => true,
        :region => 'us-west-1'
      )
      s3 = Heirloom::AWS::SimpleDB.new :config => config

    end

  end

  # Data recorded with VCR after running ./spec/fixtures/create_test_data.sh
  # To re-record VCR data:
  # 1) Delete relevant YAML files in spec/fixtures/cassettes
  # 2) Replace mock_config with Heirloom.load_config!
  # 3) Run integration specs: $ HEIRLOOM_INTEGRATION=true rake spec
  context "select", :vcr => true, :integration => true do
    
    before do
      @sdb = Heirloom::AWS::SimpleDB.new :config => (Heirloom::Config.new :environment => 'integration')
      @q = "select * from `heirloom_test_data` where built_at > '2000-01-01T00:00:00.000Z' order by built_at desc"
    end

    it "should get results" do
      keys = @sdb.select(@q).keys
      keys.size.should == 10
      keys.first.should == "v10"
    end

    it "should be able to offset results" do
      keys = @sdb.select(@q, :offset => 2).keys
      keys.size.should == 8
      keys.first.should == "v8"
    end

    it "should yield when requested" do
      num_yields = 0
      @sdb.select(@q, :offset => 2) do |k, v|
        num_yields += 1
      end
      num_yields.should == 8
    end

  end

  context "sdb operations" do

    before do
      @fog_mock = mock 'fog'
      Fog::AWS::SimpleDB.stub :new => @fog_mock
      @sdb = Heirloom::AWS::SimpleDB.new :config => mock_config
    end

    it "should list the domains in simples db" do
      body_mock = mock 'body'
      @fog_mock.should_receive(:list_domains)
        .and_return body_mock
      body_mock.should_receive(:body)
        .and_return 'Domains' => ['domain1']
      @sdb.domains.should == ['domain1']
    end

    it "should create a new domain when it does not exist" do
      @sdb.should_receive(:domains).and_return([])
      @fog_mock.should_receive(:create_domain).with('new_domain')
      @sdb.create_domain('new_domain')
    end

    it "should destroy the specified domain" do
      @fog_mock.should_receive(:delete_domain).with('new_domain')
      @sdb.delete_domain('new_domain')
    end

    it "should not create a new domain when already exists" do
      @sdb.should_receive(:domains).and_return(['new_domain'])
      @fog_mock.should_receive(:create_domain).exactly(0).times
      @sdb.create_domain('new_domain')
    end

    it "should update the attributes for an entry" do
      @fog_mock.should_receive(:put_attributes).
        with('domain', 'key', {'key' => 'value'}, { "option" => "123" })
      @sdb.put_attributes('domain', 'key', {'key' => 'value'}, { "option" => "123" })
    end

    it "should delete the given entry from sdb" do
      @fog_mock.should_receive(:delete_attributes).with('domain', 'key')
      @sdb.delete('domain', 'key')
    end

    context "testing counts" do
      before do
        @body_stub = stub 'body'
      end

      it "should count the number of entries in the domain" do
        data = { 'Items' => { 'Domain' => { 'Count' => ['1'] } } }
        @fog_mock.should_receive(:select)
          .with('SELECT count(*) FROM `heirloom_domain`')
          .and_return @body_stub
        @body_stub.stub :body => data
        @sdb.count('heirloom_domain').should == 1
      end

      it "should return true if no entries for the domain" do
        data = { 'Items' => { 'Domain' => { 'Count' => ['0'] } } }
        @fog_mock.should_receive(:select)
          .with('SELECT count(*) FROM `heirloom_domain`')
          .and_return @body_stub
        @body_stub.stub :body => data
        @sdb.domain_empty?('heirloom_domain').should be_true
      end

      it "should return false if entries exist for the domain" do
        data = { 'Items' => { 'Domain' => { 'Count' => ['50'] } } }
        @fog_mock.should_receive(:select)
          .with('SELECT count(*) FROM `heirloom_domain`')
          .and_return @body_stub
        @body_stub.stub :body => data
        @sdb.domain_empty?('heirloom_domain').should be_false
      end

      it "should return the count for a specific itemName within a domain" do
        data = { 'Items' => { 'Domain' => { 'Count' => ['1'] } } }
        @fog_mock.should_receive(:select)
          .with("SELECT count(*) FROM `heirloom` WHERE itemName() = 'archive'")
          .and_return @body_stub
        @body_stub.stub :body => data
        @sdb.item_count('heirloom', 'archive').should == 1
      end
    end
  end
end
