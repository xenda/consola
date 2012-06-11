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
#  Welcome to Consola, your friendly Ruby web-console
#  ==================================================
#  Just type your Ruby code and press Ctrl+Enter
#  (Cmd+Enter if you're on a Mac) or that big button
#  below made for our keyboard-impaired brothers
#
#  For example, you could type:

3.times do
  puts 'OMG THIS IS SO AMAZING'
end

#  Or whatever. I'm not your mother.
#
#  Another useless project made by
#  Alvaro Pereyra (@Yaraher) - alvaro@xenda.pe
#  http://xenda.pe

CODE
  haml :index
end

get '/application.js' do
  coffee :application
end

post "/process" do
  result = Sicuro.eval(params[:code])
  response = { :value => escape_html(result.value),
               :return => escape_html(result.return)
             }
  response.merge!({:error => result.exception}) unless result.exception == ""
  response.to_json
end