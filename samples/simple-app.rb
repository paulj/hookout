require 'rubygems'
require 'sinatra'
  
get '/' do
  "Hello World"
end

get '/ruby/' do
  "Hello world from /ruby/"
end
