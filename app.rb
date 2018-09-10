require 'sinatra'


get '/' do
  haml :readme
end 
