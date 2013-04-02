require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do
    @archive_mock = mock 'archive'
  end

  it "should download, decrypt, then re-encrypt the archive" do

    @cli_rotate = Heirloom::CLI::Rotate.new

    @cli_rotate.should_receive(:download)
    @cli_rotate.should_receive(:rotate)
    @cli_rotate.should_receive(:upload)

  end
  
end
