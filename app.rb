require 'sinatra'
require 'rest-client'

require_relative './lib/converter.rb'
use Rack::Logger

set :show_exceptions, false

# allow all js application to call us
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

error Converter::InvalidParameter do
  status 422 # unprocessable entity
  env['sinatra.error'].message
end

error Converter::ApiError do
  status 503 # temporarily unavailable
  request.logger.error("API error: #{env['sinatra.error'].message}")
  env['sinatra.error'].message
end

get '/' do
  Converter
    .new(request.logger)
    .convert(params[:from], params[:to], params[:value])
    .to_s
end
