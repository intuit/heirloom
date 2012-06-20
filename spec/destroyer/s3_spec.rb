require 'spec_helper'

describe Heirloom do

    before do
      @config_mock = double 'config'
      @s3 = Heirloom::Destroyer::S3.new :config  => @config_mock,
                                        :region  => 'us-west-1'
    end

    it "should delete the specified file from s3" do
      s3_mock = mock 's3 mock'
      @s3.should_receive(:s3).and_return(s3_mock)
      s3_mock.should_receive(:delete_object).
              with('bucket', "key_folder/key_name")
      @s3.destroy_file :key_name   => 'key_name',
                       :key_folder => 'key_folder',
                       :bucket     => 'bucket'
    end

end
