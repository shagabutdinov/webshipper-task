require 'spec_helper'
require 'rack/test'

require_relative '../app'

# acceptance test; will invoke live http request to external API
describe 'App', type: :feature do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'says hello' do
    get '/', from: 'EUR', to: 'USD', value: '100'
    expect(last_response).to be_ok

    # give generous 50 points value range to make sure test will not break
    # after next financial crysis
    expect(Float(last_response.body)).to be_within(50).of(115)
  end
end
