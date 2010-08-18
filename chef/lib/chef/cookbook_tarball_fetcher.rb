
require 'open-uri'

class Chef
  class CookbookTarballFetcher

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def write_archive_to(destination)
      Chef::Log.info("Fetching cookbook tarball from #@url")
      open(@url) do |remote_tgz|
        unzip_io(remote_tgz) do |remote_unzipped|
          Chef::Log.info("Writing cookbook tar archive to #{destination}")
          File.open(destination, 'ab') do |unzipped_file|
            while chunk = remote_unzipped.read(8192)
              unzipped_file << chunk
            end
          end
        end
      end
    end

    private

    # Zlib::GzipReader.new accepts IO objects, but doesn't take a block.
    # Zlib::GzipReader.open takes a block but only works for files.
    # unzip_io does what we want, which is work with an IO object and take
    # a block.
    def unzip_io(io)
      unzipped_io = Zlib::GzipReader.new(io)
      yield unzipped_io
    ensure
      unzipped_io.close if unzipped_io
    end

  end
end
