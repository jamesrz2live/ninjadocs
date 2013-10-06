require "#{File.dirname(__FILE__)}/../lib/generator"
require 'tmpdir'

module NinjaDocsGeneratorSpec
  class Helper
    attr_reader :searchRoot, :htmlRoot

    def initialize
      @searchRoot = "#{File.dirname(__FILE__)}/../docs"
      # @htmlRoot = Dir.mktmpdir
      @htmlRoot = "/tmp/ninjadocs"
    end

    def clean
      system "rm -fr #{@htmlRoot}/ #{@searchRoot}/index.html"
      system "mkdir -p #{@htmlRoot}"
    end
  end
end

describe 'NinjaDocs::Generator' do
  let(:nd) { NinjaDocs::Generator.new }
  specify { nd.should respond_to(:generate) }
end

describe 'NinjaDocs::Generator#generate' do
  let(:helper) { NinjaDocsGeneratorSpec::Helper.new() }

  let(:nd) { 
    NinjaDocs::Generator.new({
      :searchRoot => helper.searchRoot,
      :htmlRoot => helper.htmlRoot
    });
  }

  before :each do
    helper.clean
    @errorCount = 0
    nd.events.on("failure") { |info| 
      @errorCount += 1 

      $stderr.puts "#{info[:srcFile]}: #{info[:error]}"
      $stderr.puts info[:backtrace]
      $stderr.puts ""
    }

    nd.generate
  end

  after :each do
    helper.clean
  end

  it "should not fail" do
    @errorCount.should == 0
  end

  it "should create a ninjadocs hidden directory in htmlRoot" do
    File.exists?("#{helper.htmlRoot}/.ninjadocs").should be_true
  end

  it "should create an html file in the htmlRoot directory called 'index.html'" do
    File.exists?("#{helper.htmlRoot}/index.html").should be_true
  end

  it "the ONLY html file in the htmlRoot directory should be 'index.html'" do
    htmlFiles = Dir.glob("#{helper.htmlRoot}/**").select { |f| File.extname(f) =~ /htm/ }
    htmlFiles.size().should == 1
    File.basename(htmlFiles[0]).should match(/^index/)
  end

  it "should create an html file for each source file" do
    srcFiles = Dir.glob("#{helper.searchRoot}/**").map {|f| File.basename(f)}
    htmlFiles = Dir.glob("#{helper.htmlRoot}/.ninjadocs/**").map {|f| File.basename(f) }
    htmlFiles << "index.html" if File.exists?("#{helper.htmlRoot}/index.html")
    srcFiles.each() { |s| 
      htmlFile = s.gsub(File.extname(s), ".html")
      htmlFiles.include?(htmlFile).should be_true 
    }
    srcFiles.size.should == htmlFiles.size
  end
end
