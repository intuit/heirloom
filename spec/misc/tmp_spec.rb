require 'spec_helper'

describe Heirloom do

  describe 'misc' do
    before do
      @object = Object.new
      @object.extend Heirloom::Misc::Tmp
    end

    it "should return a temporary archive file" do
      Kernel.stub :rand => 0
      Dir.stub :tmpdir => '/tmp'
      @object.random_archive.should == '/tmp/AAAAAAAA.tar.gz'
    end

  end

end
