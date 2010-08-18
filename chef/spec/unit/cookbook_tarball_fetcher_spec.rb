require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chef::CookbookTarballFetcher do
  before do
    @tarball_fetcher = Chef::CookbookTarballFetcher.new('http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz')
  end

  it "has the url of the remote cookbook tarball" do
    @tarball_fetcher.url.should == "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
  end

  it "writes the unzipped tarball to a given path" do
    url = "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
    gzipped_io = StringIO.new(IO.read(File.join(CHEF_SPEC_DATA, 'foo.gz')))
    @tarball_fetcher.should_receive(:open).with(url).and_yield(gzipped_io)
    Tempfile.open("chef-spec-#{File.basename(__FILE__)}-#{__LINE__}") do |tempfile|
      tempfile.close
      @tarball_fetcher.write_archive_to(tempfile.path)

      IO.read(tempfile.path).should == "ohai to you foo\n"
    end
  end

end