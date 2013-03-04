require "rubygems"
require 'bundler'
require "bundler/setup"
Bundler.require

require "sinatra"
require "sinatra/config_file"
require 'haml'  
config_file 'config.yml'
get '/' do
  haml :index, :locals => {:id => nil}
end

get '/location/:lat/:long' do
  response = query_foursquare(params[:lat], params[:long])
  data = response.venues.sort{|a,b| a.location.distance <=> b.location.distance}
  haml :list, :locals => {:data => data}, :layout => false
end

post '/yes/:id' do
  puts "Yes value"
  puts params
  haml :index, :locals => {:id => params[:id]}
end

get '/yes/:id' do
  puts params
  haml :index, :locals => {:id => params[:id]}
end

post '/no/:id' do
  puts "no value"
  puts params
  haml :index, :locals => {:id => params[:id]}
end

get '/(yes|no)/:id' do
  haml :index, :locals => {:id => params[:id]}
end


get '/venue/:id' do
  yes = rand(10...100) * 1.0
  no = rand(10...100) * 1.0
  total = (yes+no)
  puts total
  haml :venue, :locals => {:yes => yes, :no => no, :total => total}, :layout => false
end


def query_foursquare(lat = 36.142064, long = -86.816086)
  conn = get_connection('https://api.foursquare.com')
  response = conn.get '/v2/venues/search',     {
      :v => 20130107,
      :ll => lat.to_s+','+long.to_s,
      :oauth_token => settings.foursquare_token
    }
  Hashie::Mash.new(JSON.parse(response.body)).response
end

def get_connection(url)
  Faraday.new(:url => url, :ssl => {:ca_file => '/Users/graemewilson/Library/Application Support/Sublime Text 2/Packages/Package Control/certs/ca-bundle.crt', :verify_mode => OpenSSL::SSL::VERIFY_PEER }) do |faraday|
    faraday.request  :url_encoded             # form-encode POST params
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  end
end