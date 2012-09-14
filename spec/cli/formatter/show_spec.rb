require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  it "should remove reserved / endpoint attribs" do
    attributes = { 'id'                  => '123',
                   'another_data'        => 'more_data',
                   'built_at'            => 'today',
                   'built_by'            => 'me',
                   'bucket_prefix'       => 'bp',
                   'us-west-1-s3-url'    => 's3',
                   'us-west-1-http-url'  => 'http',
                   'us-west-1-https-url' => 'https' }
    formatter = Heirloom::CLI::Formatter::Show.new
    Kernel.should_receive(:puts).with('id           : 123')
    Kernel.should_receive(:puts).with('another_data : more_data')
    formatter.display :attributes => attributes
  end

end
