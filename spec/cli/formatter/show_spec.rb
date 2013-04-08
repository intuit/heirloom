require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @attributes = { 'id'                  => '123',
                    'another_data'        => 'more_data',
                    'built_at'            => 'today',
                    'built_by'            => 'me',
                    'bucket_prefix'       => 'bp',
                    'us-west-1-s3-url'    => 's3',
                    'us-west-1-http-url'  => 'http',
                    'us-west-1-https-url' => 'https',
                    'us-west-1-perms'     => 'rickybobby:full-control',
                    'us-west-2-perms'     => 'rickybobby:full-control' }
  end

  it "should remove reserved / endpoint attribs" do
    formatter = Heirloom::CLI::Formatter::Show.new
    formatter.format(:attributes => @attributes).
              should_not match 'bucket_prefix|us-west-1-s3-url'
  end

  it "should format the id output correctly" do
    formatter = Heirloom::CLI::Formatter::Show.new
    formatter.format(:attributes => @attributes).
              should == "id           : 123\nanother_data : more_data"
  end

end
