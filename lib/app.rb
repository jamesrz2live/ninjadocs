module NinjaDocs

  class App

    def initialize args
      parseArgs args
    end

    def run
      NinjaDocs.makeDocs @cli[:in]
    end

    def parseArgs args

      @cli = Trollop::options do
        opt :in, 'Input directory paths', :type => :strings, :multi, :required => true
        opt :out, 'Path where generated files should appear', :type => :string
        opt :no_colors, 'Disable colors?'
      end

      @cli[:in].delete_if() { |path| not File.directory? path }

      Trollop::die "No input paths were specified or valid." if @cli[:in].empty?

    end

  end

end

