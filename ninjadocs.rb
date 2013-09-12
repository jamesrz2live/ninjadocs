#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

require 'rubygems'
require 'kramdown'
require 'haml'

module NinjaDocs
  module Colors
    def colorize(code, str)
      "\e[#{code}m#{str}\e[0m"
    end

    def red str
      colorize 31, str
    end

    def green str
      colorize 32, str
    end

    def yellow str
      colorize 33, str
    end

    def blue str
      colorize 34, str
    end

    def pink str
      colorize 35, str
    end

    def gray str
      colorize 37, str
    end
  end

  class Generator
    include Colors

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
      { :root => Dir.getwd, :html => Dir.getwd, :v => false }.merge!(opts)
      @searchRoot = File.expand_path opts[:root]
      @htmlRoot = File.expand_path opts[:html]
      @ninjaRoot = File.join @htmlRoot, '.ninjadocs/'
      @docs = []
      @errors = []
      @indexFilepath = File.join @htmlRoot, 'docs.html'
      @verbose = true
      @colors = true
    end

    def generate
      if @verbose
        $stdout.puts "#{blue('☯ NinjaDocs')}"
        $stdout.puts "(working in #{@searchRoot})"
      end
      
      _purify
      _prepare
      _ninjitsu

      if @errors.length > 0
        $stdout.puts red('☠ NinjaDocs ლ(ಠ益ಠლ)')
        abort
      else
        $stdout.puts green('✌ NinjaDocs') if @verbose
      end
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
      files = []
      Dir.chdir(@searchRoot) { 
        files = Dir.glob("**/*").collect { |f| File.expand_path f }
      }
      return files
    end

    def _relativePath path, root
      Pathname.new(path).relative_path_from(Pathname.new(root))
    end

    def _ninjitsu
      _globSrcFiles().each { |f| _makeNinjaDoc f }
      _makeIndexFile
    end

    def _makeNinjaDoc srcFile
      return unless srcFile[/.*(#{FILE_EXTENSIONS.join('|')})/, 1]
      
      fout = File.expand_path(_relativePath(srcFile, @searchRoot)).gsub(".md", ".html")
    
      html = Kramdown::Document.new(IO.read(srcFile)).to_html()
      File.open(fout, 'w') { |fstream| fstream.write(html) }

      $stdout.puts "#{green('✔')} #{srcFile}" if @verbose
      @docs << { :href => fout, :name => File.basename(fout, '.*').gsub("_", " ") }
    rescue => exception
      $stdout.puts "#{red('✘')} #{srcFile}"
      $stderr.puts "'#{srcFile}' => #{exception.message}"
      @errors << exception
    end

    def _makeIndexFile
      t = File.expand_path File.join(File.dirname(__FILE__), 'templates', 'docs.haml')
      html = Haml::Engine.new(IO.read(t)).render(self)
      File.open(@indexFilepath, 'w') { |fstream| fstream.write html }
      $stdout.puts "#{green('★')} #{@indexFilepath}" if @verbose
    rescue => exception
      $stderr.puts "#{red('✘')} #{@indexFilepath}"
      $stderr.puts "Render '#{File.basename @indexFilepath}' => exception: #{exception.message}"
      @errors << exception
    end
  end

  def self.makeDocs path
    c14npath = File.expand_path path
    raise "Are you crazy?! '#{c14npath}' isn't a directory, bro." unless File.directory? c14npath
    Dir.chdir(c14npath) { |p| NinjaDocs::Generator.new({ :root => p, :html => p }).generate() }
  end
end

if __FILE__ == $0
  ARGV.select { |arg| File.directory? arg }.each { |path|
    NinjaDocs.makeDocs path
  }
end
