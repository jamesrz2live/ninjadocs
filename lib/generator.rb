require "#{File.dirname(__FILE__)}/events"
require 'fileutils'
require 'pathname'
require 'rubygems'
require 'kramdown'
require 'haml'

module NinjaDocs

  class Generator
    attr_accessor :events
    attr_reader :errors

    FILE_EXTENSIONS = [
      'markdown',
      'mdown',
      'mkdn',
      'md',
      'mkd',
      'mdwn',
      'mdtxt',
      'mdtext',
      'text',
      'page'
    ]

    def initialize opts = {}
      @searchRoot = Dir.getwd
      @searchRoot = File.expand_path opts[:searchRoot] if opts[:searchRoot]
      @htmlRoot = Dir.getwd
      @htmlRoot = File.expand_path opts[:htmlRoot] if opts[:htmlRoot]
      @events = Events.new
      @ninjaRoot = File.expand_path "#{@htmlRoot}/.ninjadocs/"
      @indexFilepath = "#{@htmlRoot}/docs.html"
      @docs = []
      @errors = []
    end

    def generate
      @events.emit "start", :searchRoot => @searchRoot, :htmlRoot => @htmlRoot

      _purify
      _prepare
      _ninjutsu

      @events.emit "finish", :errors => @errors, :srcFiles => _globSrcFiles(), :htmlFiles => @docs
    end

  private
    def _purify
      FileUtils.rm @indexFilepath if File.exist? @indexFilepath
      FileUtils.rm_r @ninjaRoot if File.exist? @ninjaRoot
    end

    def _prepare
      FileUtils.mkdir_p @htmlRoot
      FileUtils.mkdir_p @ninjaRoot
    end

    def _globSrcFiles
      Dir.glob("#{@searchRoot}/**/*").select { |f| 
        f[/.*(#{FILE_EXTENSIONS.join('|')})/, 1] 
      }.collect { |f| 
        File.expand_path f 
      }
    end

    def _relativePath path, root
      Pathname.new(path).relative_path_from(Pathname.new(root))
    end

    def _ninjutsu
      _globSrcFiles().each { |f| _makeNinjaDoc f }
      @docs.each() { |d| _writeDoc d }
      _copyJavaScript
    end

    def _makeNinjaDoc srcFile
      fout = "#{_relativePath(srcFile, @searchRoot)}".gsub('.md', '.html')
      if fout.include? 'index.html'
        fout = "#{@htmlRoot}/index.html"
      else
        fout = "#{@ninjaRoot}/#{fout}"
        FileUtils.mkdir_p File.dirname(fout)
      end
      @docs << { :href => fout, :name => File.basename(fout, '.*').gsub("_", " "), :src => srcFile }
    rescue Exception => e
      @events.emit "failure", :srcFile => srcFile, :error => e.message, :backtrace => e.backtrace
      @errors << e
    end

    def _setTemplateVars doc
      src = doc[:src] ? IO.read(doc[:src]) : doc[:body]
      @body = Kramdown::Document.new(src).to_html
      @jsPath = "#{@ninjaRoot}/js"
    end

    def _writeDoc doc
      _setTemplateVars doc
      
      t = File.expand_path File.join(File.dirname(__FILE__), '..', 'views', 'docs.haml')
      fout = File.expand_path doc[:href]
      File.open(fout, 'w') { |fstream| fstream.write Haml::Engine.new(IO.read(t)).render(self) }
      
      @events.emit "success", :srcFile => doc[:src]
    rescue Exception => e
      @events.emit "failure", :srcFile => doc[:src], :error => e.message, :backtrace => e.backtrace
      @errors << e
    end

    def _copyJavaScript
      FileUtils.mkdir_p "#{@ninjaRoot}/js"
      FileUtils.cp_r("#{File.dirname(__FILE__)}/../js/", "#{@ninjaRoot}")
    rescue Exception => e
      @errors << e
    end
  
  end

end
