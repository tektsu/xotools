require 'spec_helper.rb'
require 'helpers/filesystem_helpers'
require 'xo/directory/link'

RSpec.configure do |c|
  c.include FileSystemHelper
end

describe Xo::Directory::Link do
  before :each do
    create_filesystem
  end

  after :each do
    remove_filesystem
  end

  describe 'initialize' do
    it 'sets the source and target directories' do
      linker = Xo::Directory::Link.new(@src, @tgt)
      expect(linker.source).to eq(@src)
      expect(linker.target).to eq(@tgt)
    end
  end
  
  describe 'process' do
    before :each do
      populate_source_directory
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