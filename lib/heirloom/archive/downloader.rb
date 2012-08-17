module Heirloom

  class Downloader

    include Heirloom::Misc::Tmp

    def initialize(args)
      @config = args[:config]
      @name = args[:name]
      @id = args[:id]
      @logger = @config.logger
    end

    def download(args)
      region = args[:region]
      base_prefix = args[:base_prefix]
      extract = args[:extract]
      output = args[:output] ||= './'

      s3_downloader = Downloader::S3.new :config => @config,
                                         :logger => @logger,
                                         :region => region

      bucket = get_bucket :region => region, :base_prefix => base_prefix

      @logger.info "Downloading s3://#{bucket}/#{key} from #{region}."
      archive = s3_downloader.download_file :bucket => bucket,
                                            :key    => key

      if extract
        extracter = Extracter.new :config => @config
        extracter.extract :archive => archive, :output => output
      else
        output_file = File.join output, file
        @logger.info "Writing archive to '#{output_file}'."
        File.open(output_file, 'w') { |local_file| local_file.write archive }
      end

      @logger.info "Download complete."
    end

    private

    def file 
      "#{@id}.tar.gz"
    end

    def key
      "#{@name}/#{file}"
    end

    def get_bucket(args)
      "#{args[:base_prefix]}-#{args[:region]}"
    end

  end
end
