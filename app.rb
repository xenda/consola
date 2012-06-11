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

  if rand(5) > 3
  example=<<RAND
10.times do
   puts "Na"
end

puts "BATMAN!"
RAND
  else
  example=<<RAND
10.downto(1) do
  puts "TIC-TIC"
end
puts "B"+"O"*10+"M"
RAND
  end

  @code =<<CODE
#
#  Welcome to Consola, your friendly Ruby web-console
#  ==================================================
#  Type some Ruby code, press Ctrl+Enter
#  (Cmd+Enter if you're on a Mac) or that big button
#  below (made for our keyboard-impaired brothers) and
#  that's it!
#
#  For example, you could type:

#{example}

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