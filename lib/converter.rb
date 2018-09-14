# Conversion logic class
class Converter
  class InvalidParameter < StandardError; end
  class ApiError < StandardError; end

  API_URL = 'https://api.exchangeratesapi.io/latest'.freeze

  def initialize(logger = Logger.new(STDOUT))
    @log = logger
  end

  def convert(from, to, value)
    parse_value(value) * exchange_rate(from, to)
  end

  private

  def parse_value(value)
    Float(value)
  rescue ArgumentError
    raise InvalidParameter, "Conversion value should be integer: #{value}"
  end

  def exchange_rate(currency_from, currency_to)
    response = raw_rates(currency_from)
    rates = extract_rates_from_response(response)
    rate = rates[currency_to.to_sym]
    raise InvalidParameter, "Unkwnown currency: #{currency_to}" if rate.nil?

    rate
  end

  def raw_rates(currency_from)
    params = [API_URL, params: { base: currency_from }]
    @log.debug("call exchangeratesapi.io: #{params}")
    response = RestClient.get(*params)
    @log.debug("exchangeratesapi.io response: #{response.body}")
    response
  rescue StandardError => error
    process_request_error(currency_from, error)
  end

  def process_request_error(currency_from, error)
    case error
    when RestClient::UnprocessableEntity
      raise InvalidParameter, "Unkwnown currency: #{currency_from}"
    when RestClient::ExceptionWithResponse
      raise ApiError, "Failed to call exchangeratesapi.io: #{error.response}"
    when RestClient::Exception
      raise ApiError, "exchangeratesapi.io is not available: #{error.message}"
    else
      raise error
    end
  end

  def extract_rates_from_response(response)
    rates = JSON.parse(response.body, symbolize_names: true)[:rates]
    if rates.nil?
      raise ApiError, 'exchangeratesapi response does not contain exchange ' \
                      "rates: #{response.body}"
    end

    rates
  rescue JSON::ParserError => error
    raise ApiError, 'Failed to parse exchangeratesapi.io response: ' \
                    "#{error.message} #{response.body}"
  end
end
