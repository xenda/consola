require 'sinatra'
require 'haml'
require "sinatra/reloader" if development?
require 'base64'
require 'sicuro'
require 'coffee-script'

get '/' do
  @code =<<CODE

"Welcome to Consola, your friendly Ruby web-console"
"=================================================="
"Just type your Ruby code and press *Send my code*"
"For example, you could type:"

puts 'OMG THIS IS SO AMAZING'

"or whatever"

"Another useless project made my Alvaro Pereyra (@Yaraher)"

CODE
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
  result = Sicuro.eval(params[:code])
  puts result.inspect
  result.value
end