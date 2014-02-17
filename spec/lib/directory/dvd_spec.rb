require 'spec_helper.rb'
require 'xo/directory/dvd'

describe Xo::Directory::Dvd do
  
  before :each do
    @source = 'sourcedir'
    @target = 'testdvd'
  end

  after :each do
    FileUtils.rm_rf(@dvd.path) if @dvd
    FileUtils.rm_rf(@source) if @source
  end

  describe 'initialize' do

    it 'creates the directory' do
      @dvd = Xo::Directory::Dvd.new(@target)
      expect(File).to exist(@dvd.path)
    end
    
    it 'reports maximum size free' do
      @dvd = Xo::Directory::Dvd.new(@target)
      expect(@dvd.remaining_space).to eq(@dvd.max_size)
    end
    
  end

  describe 'add' do
    
    before :each do
      @source = 'sourcedir'
      @dvd = Xo::Directory::Dvd.new(@target)
      FileUtils.mkpath(@source)
    end

    after :each do
      FileUtils.rm_rf(@source) if Dir.exists?(@source)
    end

    it 'adds a file small enough to fit' do
      file = "#{@source}/file1"
      File.open(file, 'wb') { |fd| fd.truncate(10000) }
      @dvd.add(file)
      expect(@dvd.current_size).to eq(10000)
    end
    
    it 'copies an added file into the dvd directory' do
      file = "#{@source}/file1"
      File.open(file, 'wb') { |fd| fd.truncate(10000) }
      @dvd.add(file)
      expect(File).to exist("#{@dvd.path}/#{File.basename(file)}")
    end
    
    it 'rejects a file too large to fit' do
      file = "#{@source}/file1"
      File.open(file, 'wb') { |fd| fd.truncate(@dvd.max_size + 1) }
      expect{ @dvd.add(file) }.to raise_error
    end
    
    it 'adds a directory small enough to fit' do
      file = "#{@source}/file1"
      File.open(file, 'wb') { |fd| fd.truncate(10000) }
      @dvd.add(@source)
      expect(@dvd.current_size).to be >= 1000
    end
    
    it 'copies an added directory into the dvd directory' do
      file = "#{@source}/file1"
      File.open(file, 'wb') { |fd| fd.truncate(10000) }
      @dvd.add(@source)
      expect(Dir).to exist("#{@dvd.path}/#{File.basename(@source)}")
    end
    
    it 'rejects a directory too large to fit' do
      5.times do |x|
        File.open("#{@source}/file#{x}", 'wb') { |fd| fd.truncate(1024 * 1024 * 1024) }
      end
      expect{ @dvd.add(source) }.to raise_error
    end
    
  end

end