module Heirloom
  class Extracter

    def initialize(args)
      @config = args[:config]
      @logger = @config.logger
    end

    def extract(args)
      @tmp_archive = Tempfile.new('archive.tar.gz').path

      create_tmp_archive args[:archive]
      extract_tmp_archive args[:output]
      delete_tmp_archive
    end

    private

    def create_tmp_archive(archive)
      File.open(@tmp_archive, 'w') { |local_file| local_file.write archive }
    end

    def extract_tmp_archive(output)
      @logger.info "Extracting archive to '#{output}'."
      cmd = "tar xzf #{@tmp_archive} -C #{output}"
      @logger.debug "Executing '#{cmd}'."
      `#{cmd}`
    end
  
    def delete_tmp_archive
      @logger.debug "Deleting '#{@tmp_archive}'."
      File.delete @tmp_archive
    end

  end
end
