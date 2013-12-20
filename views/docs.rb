require 'rubygems'
require 'mustache'

module Views
  class Docs < Mustache
    @body = ''
    @title = ''
    attr_accessor :body, :title
  end
end
