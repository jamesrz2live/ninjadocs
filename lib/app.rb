require "#{File.dirname(__FILE__)}/generator"
require 'trollop'

module NinjaDocs

  class App
    def initialize args
      parseArgs args
      @generator = Generator.new
    end

    def run
      generatorEvents = @generator.events

      generatorEvents.on("start") { |info|
        $stdout.puts '☯ NinjaDocs'
        $stdout.puts "(working in #{info[:searchRoot]})"
      }

      generatorEvents.on("finish") { |info|
        if info[:errors].length > 0
          $stdout.puts '☠ NinjaDocs ლ(ಠ益ಠლ)'
          exit 1
        else
          $stdout.puts '✌ NinjaDocs'
        end
      }

      generatorEvents.on("failure") { |info|
        $stdout.puts "#{red('✘')} #{info[:srcFile]}"
        $stderr.puts "'#{info[:srcFile]}' => #{info[:error]}"
      }

      generatorEvents.on("success") { |info|
        $stdout.puts "#{green('✔')} #{info[:srcFile]}"
      }

      @generator.generate @cli[:in]
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

