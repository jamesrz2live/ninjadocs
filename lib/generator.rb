require "#{File.dirname(__FILE__)}/events"
require 'fileutils'
require 'pathname'
require 'rubygems'
require 'kramdown'
require 'haml'

module NinjaDocs

=begin

# NinjaDocs::Generator

`Generator` creates HTML files by scanning the specified path for source files
and running them through Kramdown. The pages it generates are created by
rendering templates using Haml.

=end

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
      @htmlRoot = opts[:htmlRoot] if opts[:htmlRoot]
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
      _ninjitsu

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

    def _ninjitsu
      _globSrcFiles().each { |f| _makeNinjaDoc f }
      @docs.each() { |d| _writeDoc d }
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
    rescue => exception
      @events.emit "failure", :srcFile => srcFile, :error => exception.message, :backtrace => exception.backtrace
      @errors << exception
    end

    def _writeDoc doc
      if doc[:src]
        @body = Kramdown::Document.new(IO.read(doc[:src])).to_html
      else
        @body = Kramdown::Document.new(doc[:body]).to_html
      end

      t = File.expand_path File.join(File.dirname(__FILE__), '..', 'views', 'docs.haml')
      fout = File.expand_path doc[:href]
      File.open(fout, 'w') { |fstream| fstream.write Haml::Engine.new(IO.read(t)).render(self) }
      srcRelativePath = _relativePath(doc[:src], @searchRoot)
      
      @events.emit "success", :srcFile => doc[:src]
    rescue => exception
      @events.emit "failure", :srcFile => doc[:src], :error => exception.message, :backtrace => exception.backtrace
      @errors << exception
    end
  
  end

end
