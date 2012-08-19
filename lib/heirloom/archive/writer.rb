module Heirloom
  class Writer

    def initialize(args)
      @config = args[:config]
      @logger = @config.logger
    end

    def save_archive(args)
      @output  = args[:output]
      @file    = args[:file]
      @archive = args[:archive]
      @extract = args[:extract]

      @extract ? extract_archive : write_archive
    end

    private

    def extract_archive
      @tmp_archive = Tempfile.new('archive.tar.gz').path

      create_tmp_archive 
      extract_tmp_archive
    end

    def write_archive
      output_file = File.join @output, @file
      @logger.info "Writing archive to '#{output_file}'."
      File.open(output_file, 'w') { |local_file| local_file.write @archive }
    end

    def create_tmp_archive
      File.open(@tmp_archive, 'w') { |local_file| local_file.write @archive }
    end

    def extract_tmp_archive
      @logger.info "Extracting archive to '#{@output}'."
      cmd = "tar xzf #{@tmp_archive} -C #{@output}"
      @logger.debug "Executing '#{cmd}'."
      `#{cmd}`
      if $?.success?
        @logger.debug "Archive succesfully extracted."
        true
      else
        @logger.error "Error extracting archive."
        false
      end
    end

  end
end
