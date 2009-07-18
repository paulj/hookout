require 'rubygems'
require 'sinatra'
require 'hookout'

set :server, 'hookout'
set :host, 'http://localhost:8000/reversehttp'
set :port, 'test-ruby-app'

get '/' do
  "Hello World"
end

get '/ruby/' do
  "Hello World"
end
