module NinjaDocs

  class Logf

    VOLUMES = {
      :debug  => 0, 
      :info   => 1, 
      :warn   => 2, 
      :error  => 3, 
      :fatal  => 4
    }

    def initialize stream = nil, opts = {}
      @stream = stream || $stdout
      @colors = opts[:colors] || true
      @volume = opts[:volume] || VOLUMES[:info]
    end

    def info message
      
