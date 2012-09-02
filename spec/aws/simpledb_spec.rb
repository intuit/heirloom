require 'spec_helper'

describe Heirloom do
  before do
    @config_mock = mock 'config'
    @config_mock.should_receive(:access_key).and_return 'the-key'
    @config_mock.should_receive(:secret_key).and_return 'the-secret'
    @config_mock.should_receive(:metadata_region).and_return 'us-west-1'
    @fog_mock = mock 'fog'
    Fog::AWS::SimpleDB.should_receive(:new).
                       with(:aws_access_key_id     => 'the-key',
                            :aws_secret_access_key => 'the-secret',
                            :region                => 'us-west-1').
                       and_return @fog_mock
    @sdb = Heirloom::AWS::SimpleDB.new :config => @config_mock
  end

  it "should list the domains in simples db" do
    body_mock = mock 'body'
    @fog_mock.should_receive(:list_domains).
              and_return body_mock
    body_mock.should_receive(:body).
              and_return 'Domains' => ['domain1']
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

  it "should count the number of entries in the domain" do
    body_mock = mock 'return body'
    data = { 'Items' => { 'Domain' => { 'Count' => ['1'] } } }
    @fog_mock.should_receive(:select).
              with('SELECT count(*) FROM `heirloom_domain`').
              and_return body_mock
    body_mock.should_receive(:body).and_return data
    @sdb.count('heirloom_domain').should == 1
  end

  it "should return true if no entries for the domain" do
    body_mock = mock 'return body'
    data = { 'Items' => { 'Domain' => { 'Count' => ['0'] } } }
    @fog_mock.should_receive(:select).
              with('SELECT count(*) FROM `heirloom_domain`').
              and_return body_mock
    body_mock.should_receive(:body).and_return data
    @sdb.domain_empty?('heirloom_domain').should be_true
  end

  it "should return false if entries exist for the domain" do
    body_mock = mock 'return body'
    data = { 'Items' => { 'Domain' => { 'Count' => ['50'] } } }
    @fog_mock.should_receive(:select).
              with('SELECT count(*) FROM `heirloom_domain`').
              and_return body_mock
    body_mock.should_receive(:body).and_return data
    @sdb.domain_empty?('heirloom_domain').should be_false
  end

  it "should return the count for a specific itemName within a domain" do
    body_mock = mock 'return body'
    data = { 'Items' => { 'Domain' => { 'Count' => ['1'] } } }
    @fog_mock.should_receive(:select).
              with("SELECT count(*) FROM `heirloom` WHERE itemName() = 'archive'").
              and_return body_mock
    body_mock.should_receive(:body).and_return data
    @sdb.item_count('heirloom', 'archive').should == 1
  end

end
