require 'spec_helper'

describe Heirloom do

  before do
    @logger_double = double 'logger', :info => true, :debug => true, :error => true
    @config_double = double 'config', :logger => @logger_mock
    @archive = Heirloom::Archive.new :config => @config_double,
                                     :name   => 'chef',
                                     :id     => '123'
  end


  context "test public methods" do

    it "should call build with given args" do
      double = double('Mock')
      Heirloom::Builder.should_receive(:new).
                        with(:config => @config_double,
                             :name   => 'chef',
                             :id     => '123').
                        and_return double
      double.should_receive(:build).with('args')
      @archive.build('args')
    end

    it "should call download method with given args" do
      double = double('Mock')
      Heirloom::Downloader.should_receive(:new).
                           with(:config => @config_double,
                                :name   => 'chef',
                                :id     => '123').
                           and_return double
      double.should_receive(:download).with('args')
      @archive.download('args')
    end

    it "should call update archive method with given args" do
      double = double('Mock')
      Heirloom::Updater.should_receive(:new).
                        with(:config => @config_double,
                             :name   => 'chef',
                             :id     => '123').
                        and_return double
      double.should_receive(:update).with('args')
      @archive.update('args')
    end

    it "should call upload archive method with given args" do
      double = double('Mock')
      reader_double = double('reader double')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_double,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_double
      reader_double.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Uploader.should_receive(:new).
                         with(:config => @config_double,
                              :name   => 'chef',
                              :id     => '123').
                         and_return double
      double.should_receive(:upload).with('arg' => 'val', :regions => ['us-west-1', 'us-west-2'])
      @archive.upload('arg' => 'val')
    end

    it "should call authorize method" do
      double = double('Mock')
      reader_double = double('reader double')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_double,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_double
      reader_double.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Authorizer.should_receive(:new).
                           with(:config => @config_double,
                                :name   => 'chef',
                                :id     => '123').
                           and_return double
      double.should_receive(:authorize).with :regions  => ['us-west-1', 'us-west-2'],
                                           :accounts => ['acct1', 'acct2']
      @archive.authorize ['acct1', 'acct2']
    end

    it "should call archive exists method and return true if archive exists" do
      double = double('Mock')
      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_double,
                            :name   => 'chef',
                            :id     => '123').
                       and_return double
      double.should_receive(:exists?).and_return true
      @archive.exists?.should be_true
    end

    it "should call archive exists method and return fasle if archive doesnt exists" do
      double = double('Mock')
      Heirloom::Reader.should_receive(:new).
                       with(:config => @config_double,
                            :name   => 'chef',
                            :id     => '123').
                       and_return double
      double.should_receive(:exists?).and_return false
      @archive.exists?.should be_false
    end

    it "should call show method"  do
      reader_double = double 'reader' 
      show_data = { 'id'               => '0.0.7',
                    'encrypted'        => 'true',
                    'bucket_prefix'    => 'rickybobby',
                    'us-west-2-s3-url' => 's3://rickybobby-us-west-2/demo2/0.0.7.tar.gz.gpg'
                  }
      object_acls_data = { 'us-west-2-perms' => 'rickybobby:read, lc:full_control',
                           'us-west-1-perms' => 'rickybobby:read, lc:full_control'
                         }
      merge_data = show_data.merge object_acls_data
 
      Heirloom::Reader.should_receive(:new).
                        with(:config => @config_double,
                             :name   => 'chef',
                             :id     => '123').
                        and_return reader_double
 
      reader_double.stub(:show).and_return(show_data)
      reader_double.stub(:object_acls).and_return(object_acls_data)
      @archive.show.should == merge_data
    end

    it "should call list method" do
      double = double('Mock')
      Heirloom::Lister.should_receive(:new).
                       with(:config => @config_double,
                            :name   => 'chef').
                       and_return double
      double.should_receive(:list)
      @archive.list
    end

    it "should return true if the required buckets exist" do
      double = double('Mock')
      Heirloom::Verifier.should_receive(:new).
                         with(:config => @config_double,
                              :name   => 'chef').
                         and_return double
      double.should_receive(:buckets_exist?).
           with(:bucket_prefix => 'test-123').and_return true
      @archive.buckets_exist?(:bucket_prefix => 'test-123').
               should be_true
    end

    it "should return false if the required buckets don't exist" do
      double = double('Mock')
      Heirloom::Verifier.should_receive(:new).
                         with(:config => @config_double,
                              :name   => 'chef').
                         and_return double
      double.should_receive(:buckets_exist?).
           with(:bucket_prefix => 'test-123').and_return false
      @archive.buckets_exist?(:bucket_prefix => 'test-123').
               should be_false
    end

    it "should call the destroy method" do
      destroyer_double = double('destroyer double')
      reader_double = double('reader double')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_double,
                               :name   => 'chef',
                               :id     => '123').
                          and_return reader_double
      reader_double.should_receive(:regions).and_return ['us-west-1', 'us-west-2']
      Heirloom::Destroyer.should_receive(:new).
                          with(:config  => @config_double,
                               :name    => 'chef',
                               :id      => '123').
                          and_return destroyer_double
      destroyer_double.should_receive(:destroy).
                     with :regions => ['us-west-1', 'us-west-2']
      @archive.destroy
    end

    it "should call the regions method for an archive" do
      double = double('Mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_double,
                               :name   => 'chef',
                               :id     => '123').
                          and_return double
      double.should_receive(:regions)
      @archive.regions
    end

    it "should call the count method for an archive" do
      double = double('Mock')
      Heirloom::Reader.should_receive(:new).
                          with(:config => @config_double,
                               :name   => 'chef',
                               :id     => '123').
                          and_return double
      double.should_receive(:count)
      @archive.count
    end

    it "should call the delete_buckets on teardowner" do
      double = double('Mock')
      Heirloom::Teardowner.should_receive(:new).
                            with(:config => @config_double,
                                 :name   => 'chef').
                          and_return double
      double.should_receive(:delete_buckets).with :regions => ['us-west-1']
      @archive.delete_buckets :regions => ['us-west-1']
    end
    
    it "should call the delete_domain on teardowner" do
      double = double('Mock')
      Heirloom::Teardowner.should_receive(:new).
                            with(:config => @config_double,
                                 :name   => 'chef').
                          and_return double
      double.should_receive(:delete_domain)
      @archive.delete_domain
    end

  end

  context "rotate" do
    before do

      @tmp_dir = '/path/to/temp/dir'
      Dir.stub(:mktmpdir).and_return @tmp_dir

      @tmp_file = double 'file'
      @tmp_file.stub :path => '/path/to/tmp/file', :close! => true
      Tempfile.stub :new => @tmp_file
      FileUtils.stub :remove_entry => true

    end

    it "should rotate an archive by downloading and re-uploading" do

      @archive.should_receive(:download).
               with(hash_including(:output => @tmp_dir, 
                                   :secret => "oldpassword",
                                   :extract => true)).
               and_return true
      @archive.should_receive(:build).
               with(hash_including(:directory => @tmp_dir,
                                   :secret => "newpassword",
                                   :file => @tmp_file.path)).
               and_return true
      @archive.should_receive(:destroy).with(no_args)
      @archive.should_receive(:upload).
               with(hash_including(:secret => "newpassword",
                                   :file => @tmp_file.path))

      @archive.rotate({ :new_secret => "newpassword", :old_secret => "oldpassword" })
    end

    context "failing download" do

      before do
        @archive.stub :download => false, :build => true, :destroy => nil, :upload => true
      end
      
      it "should raise an exception when download fails" do
        expect {
          @archive.rotate({ :new_secret => "new", :old_secret => "old" }) 
        }.to raise_error Heirloom::Exceptions::RotateFailed
      end

      it "should not destroy the file when download fails" do
        @archive.should_not_receive(:destroy)
        begin
          @archive.rotate({ :new_secret => "new", :old_secret => "old" })
        rescue Heirloom::Exceptions::RotateFailed
        end
      end

    end

    context "failing build" do

      before do
        @archive.stub :download => true, :build => false, :destroy => nil, :upload => true
      end
      
      it "should raise an exception when build fails" do
        expect {
          @archive.rotate({ :new_secret => "new", :old_secret => "old" })
        }.to raise_error Heirloom::Exceptions::RotateFailed
      end

      it "should not destroy the file when build fails" do
        @archive.should_not_receive(:destroy)
        begin
          @archive.rotate({ :new_secret => "new", :old_secret => "old" }) 
        rescue Heirloom::Exceptions::RotateFailed
        end
      end

    end

  end
end
