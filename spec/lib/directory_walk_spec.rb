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

    it "is not verbose" do
      walker = Xo::Directory::Walk.new('foo')
      expect(walker.verbose?).to be(false)
    end

    it "is verbose when verbose has been set" do
      walker = Xo::Directory::Walk.new('foo')
      walker.verbose(true)
      expect(walker.verbose?).to be(true)
    end

    it "is verbose when verbose has been set implicitly" do
      walker = Xo::Directory::Walk.new('foo')
      walker.verbose
      expect(walker.verbose?).to be(true)
    end

    it "is verbose when verbose has been set through the constructor" do
      walker = Xo::Directory::Walk.new('foo', verbose: true)
      expect(walker.verbose?).to be(true)
    end
  end
end