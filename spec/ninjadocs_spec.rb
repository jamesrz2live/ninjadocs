require "#{File.dirname(__FILE__)}/../lib/app"
require 'tmpdir'

module NinjaDocsSpec
  class Helper
    attr_reader :tmpDir, :searchRoot

    def initialize
      @tmpDir = Dir.mktmpdir
      @searchRoot = "#{File.dirname(__FILE__)}/../docs"
    end

    def clean
      system "rm -rf #{@tmpDir} && mkdir -p #{@tmpDir}"
    end

    def deployNinjaDocs
      system "cp -R #{File.dirname(__FILE__)}/../ #{@tmpDir}"
    end
  end
end

describe "NinjaDocs::App" do
  before :each do
    @helper = NinjaDocsSpec::Helper.new
    @args = "--in #{@helper.searchRoot} --out #{@helper.tmpDir} -q"
    @app = NinjaDocs::App.new(@args)
  end

  after :each do
    @helper.clean
  end

  describe "#new" do
    specify {@app.should_not be_nil}
    specify {@app.should respond_to(:run)}
    specify {@app.should respond_to(:parseArgs)}
  end

  describe "#parseArgs" do
    it "should parse args successfully" do
      @app.parseArgs(@args)
      @app.cli.should_not be_nil
      @app.cli[:in].flatten().join().should match(@helper.searchRoot)
    end
  end

  describe "#run" do
    it "should invoke NinjaDocs::Generator#generate" do
      g = double('NinjaDocs::Generator')
      g.stub(:generate)
      g.stub(:events).and_return(NinjaDocs::Events.new)
      NinjaDocs::Generator.stub(:new).and_return(g)
      @app.run
      g.should have_received(:generate).once
    end
  end
end

describe "Using ninjadocs" do
  before :each do
    @helper = NinjaDocsSpec::Helper.new
    @helper.clean
    @helper.deployNinjaDocs
    system "ruby #{@helper.tmpDir}/ninjadocs -q --in #{@helper.tmpDir} --out #{@helper.tmpDir}" 
  end

  after :each do
    @helper.clean
  end

  it "should create an 'index.html' file" do
    File.exists?("#{@helper.tmpDir}/index.html").should be_true
  end
end
