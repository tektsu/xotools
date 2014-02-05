require 'spec_helper.rb'
require 'helpers/filesystem_helpers'
require 'xo/directory/walk'

RSpec.configure do |c|
  c.include FileSystemHelper
end

describe Xo::Directory::Walk do

  describe 'initialize' do
    it 'sets the directory to be examined' do
      walker = Xo::Directory::Walk.new('foo')
      expect(walker.directory).to eq('foo')
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
    
    it 'processes all files and directories' do
      found = []
      cb = lambda {|path| found.push(path)}
      Xo::Directory::Walk.new(@src, dir_cb: cb, file_cb: cb).process
      @files.each {|file| expect(found).to include(file)}
      @dirs.each {|dir| expect(found).to include(dir)}
    end
  end
end