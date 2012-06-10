require 'sinatra'
require 'haml'
require "sinatra/reloader" if development?
require 'base64'
require 'sicuro'
require 'coffee-script'

helpers do
  include Rack::Utils
  alias_method :h, :escape
end

get '/' do
  @code =<<CODE
#
#  Welcome to Consola, your friendly Ruby web-console"
#  =================================================="
#  Just type your Ruby code and press Ctrl+Enter (or Cmd+Enter)"
#  or that big button below made for our keyboard-impaired brothers"
#  For example, you could type:"
#

3.times do
  puts 'OMG THIS IS SO AMAZING'
end

# or whatever. I'm not your mother. Are you calling me fat?
#
# Another useless project made by Alvaro Pereyra (@Yaraher)
# alvaro@xenda.pe - http://xenda.pe

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