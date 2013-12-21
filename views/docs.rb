require 'rubygems'
require 'mustache'

module Views
  class Docs < Mustache
    @body = ''
    @title = ''
    @css_path = ''
    attr_accessor :body, :title, :css_path
  end
end
