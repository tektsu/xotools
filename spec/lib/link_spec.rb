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
    
    it "is not verbose" do
      linker = Xo::Directory::Link.new("foo", "bar")
      expect(linker.verbose?).to be(false)
    end
    
    it "is verbose when verbose has been set" do
      linker = Xo::Directory::Link.new("foo", "bar")
      linker.verbose(true)
      expect(linker.verbose?).to be(true)
    end
    
    it "is verbose when verbose has been set implcitly" do
      linker = Xo::Directory::Link.new("foo", "bar")
      linker.verbose
      expect(linker.verbose?).to be(true)
    end
  end
  
  describe 'process' do
    before :each do
      create_filesystem
      populate_source_directory
    end
    
    after :each do
      remove_filesystem
    end

    it 'sets an empty target to match the source' do
      linker = Xo::Directory::Link.new(@src, @tgt)
      linker.process
      test_target_directory
    end
    
    it 'sets a partially populated target to match the source' do
      linker = Xo::Directory::Link.new(@src, @tgt)
      linker.process
      FileUtils.rm_rf("#{@tgt}/#{@dirs[1]}")
      linker.process
      test_target_directory
    end
    
    it "fixes an incorrect link" do
      linker = Xo::Directory::Link.new(@src, @tgt)
      linker.process
      FileUtils.rm_rf("#{@tgt}/#{@files[0]}")
      FileUtils.symlink("#{@src}/#{@files[1]}", "#{@tgt}/#{@files[0]}")
      linker.process
      test_target_directory
    end
    
    it "preserves existing files in the target directory"
    it "preserves existing directories in the target directory"
    it "ignores source files that are links to nonexistent files"
    it "throws an exception when a file is in the way of a link"
  end
end