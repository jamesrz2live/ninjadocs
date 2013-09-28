module NinjaDocs

=begin

# NinjaDocs::Generator

`Generator` creates HTML files by scanning the specified path for source files
and running them through Kramdown. The pages it generates are created by
rendering templates using Haml.

=end

  class Generator

    include NinjaDocs::Colors

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
      @ninjaRoot = File.expand_path "#{@htmlRoot}/.ninjadocs/"
      @docs = []
      @errors = []
      @indexFilepath = File.join @htmlRoot, 'docs.html'
      @verbose = true
      @colors = true
    end

    def generate
      if @verbose
        $stdout.puts '☯ NinjaDocs'
        $stdout.puts "(working in #{@searchRoot})"
      end
      
      _purify
      _prepare
      _ninjitsu

      if @errors.length > 0
        $stdout.puts '☠ NinjaDocs ლ(ಠ益ಠლ)'
        abort
      else
        $stdout.puts '✌ NinjaDocs' if @verbose
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
      end
      @docs << { :href => fout, :name => File.basename(fout, '.*').gsub("_", " "), :src => srcFile }
    rescue => exception
      $stdout.puts "#{red('✘')} #{_relativePath(srcFile, @searchRoot)}"
      $stderr.puts "'#{srcFile}' => #{exception.message}"
      @errors << exception
    end

    def _writeDoc doc
      if doc[:src]
        @body = Kramdown::Document.new(IO.read(doc[:src])).to_html
      else
        @body = Kramdown::Document.new(doc[:body]).to_html
      end

      t = File.expand_path File.join(File.dirname(__FILE__), 'templates', 'docs.haml')
      fout = File.expand_path doc[:href]
      File.open(fout, 'w') { |fstream| fstream.write Haml::Engine.new(IO.read(t)).render(self) }
      srcRelativePath = _relativePath(doc[:src], @searchRoot)
      $stdout.puts "#{green('✔')} #{srcRelativePath}"
    rescue => exception
      $stderr.puts "#{red('✘')} #{srcRelativePath}"
      $stderr.puts "Render '#{srcRelativePath}' => exception: #{exception.message}"
      @errors << exception
    end
  
  end

end
