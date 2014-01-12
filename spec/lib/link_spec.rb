require 'spec_helper.rb'
require 'xo/directory/link'

describe Xo::Directory::Link do
  before :each do
    @pwd = Dir.pwd
    @tmp = File.join(File.dirname(__FILE__), 'tmp')
    @tgt = "#{@tmp}/target"
    @src = "#{@tmp}/source"
    FileUtils.mkdir_p(@tgt)
    FileUtils.mkdir_p(@src)
    Dir.chdir(@tmp)
  end

  after :each do
    Dir.chdir(@pwd)
    FileUtils.rm_rf(@tmp)
  end

  describe 'initialize' do
    it 'sets the source and target directories' do
      linker = Xo::Directory::Link.new(@src, @tgt)
      expect(linker.source).to eq(@src)
      expect(linker.target).to eq(@tgt)
    end
  end
  
  describe 'process' do
    it 'sets an empty target to match the source' do
      dirs = []
      dirs.push("dir1")
      dirs.push("dir1/dir1a")
      dirs.push("dir2")
      dirs.each do |dir|
        FileUtils.mkdir_p("#{@src}/#{dir}")
      end
      files = []
      files.push("#{dirs[0]}/file1")
      files.push("#{dirs[0]}/file2")
      files.push("#{dirs[1]}/file3")
      files.each do |file|
        FileUtils.touch("#{@src}/#{file}")
      end
      linker = Xo::Directory::Link.new(@src, @tgt)
      linker.process
      files.each do |file|
        target = "#{@tgt}/#{file}"
        source = "#{@src}/#{file}"
        expect(File).to exist(target)
        expect(File.symlink?(target)).to be(true)
        expect(File.readlink(target)).to eq(source)
      end
    end
    
    it 'sets a partially populated target to match the source' do
      dirs = []
      dirs.push("dir1")
      dirs.push("dir1/dir1a")
      dirs.push("dir2")
      dirs.each do |dir|
        FileUtils.mkdir_p("#{@src}/#{dir}")
      end
      files = []
      files.push("#{dirs[0]}/file1")
      files.push("#{dirs[0]}/file2")
      files.push("#{dirs[1]}/file3")
      files.each do |file|
        FileUtils.touch("#{@src}/#{file}")
      end
      linker = Xo::Directory::Link.new(@src, @tgt)
      linker.process
      FileUtils.rm_rf("#{@tgt}/#{dirs[1]}")
      linker.process
      files.each do |file|
        target = "#{@tgt}/#{file}"
        source = "#{@src}/#{file}"
        expect(File).to exist(target)
        expect(File.symlink?(target)).to be(true)
        expect(File.readlink(target)).to eq(source)
      end
      dirs.each do |dir|
        expect(Dir).to exist("#{@src}/#{dir}")
      end
    end
  end
end