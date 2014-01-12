module FileSystemHelper
  def create_filesystem
    @pwd = Dir.pwd
    @tmp = File.join(File.dirname(__FILE__), 'tmp')
    @tgt = "#{@tmp}/target"
    @src = "#{@tmp}/source"
    FileUtils.mkdir_p(@tgt)
    FileUtils.mkdir_p(@src)
    Dir.chdir(@tmp)
  end

  def remove_filesystem
    Dir.chdir(@pwd)
    FileUtils.rm_rf(@tmp)
  end

  # Set up a sample directory structure
  def populate_source_directory
    @dirs = []
    @dirs.push("dir1")
    @dirs.push("dir1/dir1a")
    @dirs.push("dir2")
    @dirs.each do |dir|
      FileUtils.mkdir_p("#{@src}/#{dir}")
    end
    @files = []
    @files.push("#{@dirs[0]}/file1")
    @files.push("#{@dirs[0]}/file2")
    @files.push("#{@dirs[1]}/file3")
    @files.each do |file|
      FileUtils.touch("#{@src}/#{file}")
    end
  end

  # Make sure the target directory structure matches the one set up by populate_source_directory
  def test_target_directory
    @files.each do |file|
      target = "#{@tgt}/#{file}"
      source = "#{@src}/#{file}"
      expect(File).to exist(target)
      expect(File.symlink?(target)).to be(true)
      expect(File.readlink(target)).to eq(source)
    end
    @dirs.each do |dir|
      expect(Dir).to exist("#{@src}/#{dir}")
    end
  end
end