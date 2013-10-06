#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/lib/generator"
require "#{File.dirname(__FILE__)}/lib/app"

NinjaDocs::App.new(ARGV).run
