require 'sinatra'
require 'haml'
require "sinatra/reloader" if development?
require 'base64'
require 'sicuro'
require 'coffee-script'

get '/' do
  @code = "puts 'Press Send and watch the magic'"
  haml :index
end

get "/process" do
  #code = Base64.decode64(params[:code])
  #res = Sicuro.eval(code).val
  #{}"Hi #{code}"
end

get '/application.js' do
  coffee :application
end

post "/process" do
  puts params.inspect
  result = Sicuro.eval(params[:code]).value
  result
end