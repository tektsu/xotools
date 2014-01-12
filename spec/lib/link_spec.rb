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
end