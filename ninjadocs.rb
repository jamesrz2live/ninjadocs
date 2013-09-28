#!/usr/bin/env ruby

# stdlib
require 'fileutils'
require 'pathname'

# gems
require 'rubygems'
require 'kramdown'
require 'haml'
require 'trollop'

module NinjaDocs
  


end

if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/lib/app"
  NinjaDocs::App.new(ARGV).run
end

