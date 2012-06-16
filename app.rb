require 'sinatra'
require 'haml'
require 'base64'
require 'sicuro'
require 'coffee-script'
require 'rspec'


if development?
  ENV["REDISTOGO_URL"] = ' redis://redistogo:7288480c5019ec217c141df2257c96ba@gar.redistogo.com:9212/' 
  require "sinatra/reloader" if development?
end

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

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

get '/snippet/:slug' do
  @code = Base64.decode64(REDIS.get(params[:slug]))
  @result = process_result(Sicuro.eval(@code).value)
  haml :index
end

get "/tutorial/:id" do
  @code =<<CODE
#
#  Create an array
#  ==================================================
CODE
  haml :tutorial
end

post "/tutorial/:id" do

  result = Sicuro.eval(params[:code])
  unless result.exception
    $value = eval(result.value) 
    puts result.inspect
  end

  documentation_formatter = RSpec.configuration.send(:built_in_formatter, :documentation).new(RSpec.configuration.output)
  reporter =  RSpec::Core::Reporter.new(documentation_formatter)
  RSpec.configuration.instance_variable_set(:@reporter, reporter)
  RSpec::Core::Runner.run(["test/consola_test.rb"])
  #documentation_formatter.examples.map(&:metadata).map{|i| i[:execution_result]}.map{|i| i[:status]}.inspect

  def res(r)
    i = r[:execution_result]
    res = {:status => i[:status]}
    res.merge!({:exception => i[:exception].message }) if i[:exception]
    res
  end

  test_results = documentation_formatter.examples.map(&:metadata).map{|i| {:results => res(i),:full_description => i[:full_description],:description => i[:description]} }

  response = { :execution => test_results }
  response.merge!({:error => result.exception}) if result.exception
  response.to_json

end


post "/process" do
  result = Sicuro.eval(params[:code])
  response = { :value => process_result(result.value),
               :return => escape_html(result.return)
             }
  response.merge!({:error => result.exception}) unless result.exception == ""
  response.to_json
end

post "/save" do
  token = "#{Time.now.to_i.to_s(36)}-#{rand(36**8).to_s(36)}"
  REDIS.set(token, Base64.encode64(params[:code]))
  token
end

def process_result(code)
  code = escape_html(code)
  code = code.gsub("\\n","<br />")
  puts code
  code
end
