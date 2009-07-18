$:.unshift File.expand_path(File.dirname(__FILE__))

require 'hookout/reversehttp_connector'
require 'hookout/rack_adapter'
require 'hookout/runner'
require 'hookout/thin_backend'
require 'rack/handler/hookout'