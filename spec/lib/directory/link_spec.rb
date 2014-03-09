require 'spec_helper.rb'
require 'helpers/filesystem_helpers'
require 'xo/directory/link'

RSpec.configure do |c|
  c.include FileSystemHelper
end

describe Xo::Directory::Link do

  describe 'initialize' do
    it 'sets the source and target directories' do
      linker = Xo::Directory::Link.new('foo', 'bar')
      expect(linker.source).to eq('foo')
      expect(linker.target).to eq('bar')
    end

    it "raise_on_error is off" do
      linker = Xo::Directory::Link.new("foo", "bar")
      expect(linker.raise_on_error?).to be(false)
    end

    it "raise_on_error is on when raise_on_error has been set" do
      linker = Xo::Directory::Link.new("foo", "bar")
      linker.raise_on_error(true)
      expect(linker.raise_on_error?).to be(true)
    end

    it "raise_on_error is on when raise_on_error has been set implicitly" do
      linker = Xo::Directory::Link.new("foo", "bar")
      linker.raise_on_error
      expect(linker.raise_on_error?).to be(true)
    end

    it "raise_on_error is on when raise_on_error has been set through the constructor" do
      linker = Xo::Directory::Link.new("foo", "bar", raise_on_error: true)
      expect(linker.raise_on_error?).to be(true)
    end
  end
  
  describe 'link' do
    before :each do
      create_filesystem
      populate_source_directory
      @linker = Xo::Directory::Link.new(@src, @tgt)
    end

    after :each do
      remove_filesystem
    end

    it 'sets an empty target to match the source' do
      @linker.link
      test_target_directory
    end

    it 'sets a partially populated target to match the source' do
      @linker.link
      FileUtils.rm_rf("#{@tgt}/#{@dirs[1]}")
      @linker.link
      test_target_directory
    end

    it "fixes an incorrect link" do
      @linker.link
      FileUtils.rm_rf("#{@tgt}/#{@files[0]}")
      FileUtils.symlink("#{@src}/#{@files[1]}", "#{@tgt}/#{@files[0]}")
      @linker.link
      test_target_directory
    end

    it "preserves existing files in the target directory" do
      extra_file = "#{@tgt}/__extra_file__"
      FileUtils.touch(extra_file)
      @linker.link
      expect(File).to exist(extra_file)
    end

    it "preserves existing directories in the target directory" do
      extra_dir = "#{@tgt}/__extra_dir__"
      FileUtils.mkdir_p(extra_dir)
      @linker.link
      expect(Dir).to exist(extra_dir)
    end

    it "ignores source files that are links to nonexistent files" do
      invalid_name = '__invalid__'
      invalid_link = "#{@src}/#{invalid_name}"
      nonexistent_file = "#{@src}/not_really_here"
      FileUtils.touch(nonexistent_file)
      FileUtils.symlink(nonexistent_file, invalid_link)
      FileUtils.rm(nonexistent_file)
      @linker.link
      expect(File).to_not exist("#{@tgt}/#{invalid_name}")
    end

    it "throws an exception when a file is in the way of a link" do
      @linker.link
      FileUtils.rm("#{@tgt}/#{@files[0]}")
      FileUtils.touch("#{@tgt}/#{@files[0]}")
      @linker.raise_on_error
      expect{@linker.link}.to raise_error
    end
    
    it "does not throw an exception when the raise flag is not set" do
      @linker.link
      FileUtils.rm("#{@tgt}/#{@files[0]}")
      FileUtils.touch("#{@tgt}/#{@files[0]}")
      expect{@linker.link}.to_not raise_error
    end
  end
end