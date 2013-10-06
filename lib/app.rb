require "#{File.dirname(__FILE__)}/generator"
require 'trollop'

module NinjaDocs

  class App
    attr_reader :cli

    def initialize args
      parseArgs args
    end

    def run
      @cli[:in].each() { |dir|
        opts = { :searchRoot => dir }
        opts[:htmlRoot] = @cli[:out] if @cli[:out]
        g = Generator.new(opts)
        setEventCallbacks g.events
        g.generate
      }
    end

    def parseArgs args
      p = Trollop::Parser.new do
        opt :in, 'Input directory paths', :type => :strings, :multi => true, :required => true
        opt :out, 'Path where generated files should appear', :type => :string
        opt :quiet, 'No output to stdout'
        # opt :no_colors, 'Disable colors?'
      end
      
      args = args.split(' ') if args.class == String
      @cli = p.parse(args)

      @cli[:in] = @cli[:in].flatten().select() { |f| File.directory?(f) }
      Trollop::die "No input paths were specified or valid." if @cli[:in].empty?
    end

    def setEventCallbacks events
      events.on("start") { |info|
        unless @cli[:quiet]
          $stdout.puts blue('☯ NinjaDocs')
          $stdout.puts "(working in #{info[:searchRoot]}, output to #{info[:htmlRoot]})"
        end
      }

      events.on("finish") { |info|
        unless @cli[:quiet]
          errors = info[:errors]
          if info[:errors].length > 0
            $stdout.puts ""
            $stdout.puts ""
            $stdout.puts red("#{errors.size} Errors:")
            errors.each() { |e| $stdout.puts e }
            $stdout.puts ""
          end
          $stdout.puts ""
          $stdout.puts "#{info[:srcFiles].size} sources => #{info[:htmlFiles].size} html files; #{errors.size} errors"
          unless errors.empty?
            $stdout.puts red("☠ NinjaDocs ლ(ಠ益ಠლ)")
          else
            $stdout.puts green("✌ NinjaDocs")
          end
        end
      }

      events.on("failure") { |info|
        unless @cli[:quiet]
          $stdout.printf red("✗")
        end

        $stderr.puts "[ERROR] #{info[:srcFile]}"
        $stderr.puts "#{info[:error]}"
        $stderr.puts info[:backtrace]
        $stderr.puts ""
      }

      events.on("success") { |info|
        $stdout.printf green("•") unless @cli[:quiet]
      }
    end

    def red text
      return "\e[31m#{text}\e[0m"
    end

    def green text
      return "\e[32m#{text}\e[0m"
    end

    def blue text
      return "\e[34m#{text}\e[0m"
    end
  end

end

