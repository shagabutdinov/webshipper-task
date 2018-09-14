require 'converter'

describe Converter do
  let(:logger) { double('Logger', debug: nil) }
  subject { Converter.new(logger) }

  before :each do
    allow(RestClient).to receive(:get).and_return(
      double(body: '{"base":"EUR","rates":{"USD":1.1}}')
    )
  end

  describe '#convert' do
    it 'converts' do
      expect(subject.convert('EUR', 'USD', 100)).to be_within(0.00001).of(110)
    end

    it 'raises if invalid float provided' do
      expect { subject.convert('EUR', 'USD', 'INVALID') }.to raise_error(
        Converter::InvalidParameter
      )
    end

    it 'reports api call to logger' do
      expect(logger).to receive(:debug).with(
        'call exchangeratesapi.io: ["https://api.exchangeratesapi.io/' \
          'latest", {:params=>{:base=>"EUR"}}]'
      )

      subject.convert('EUR', 'USD', 100)
    end

    it 'calls api' do
      expect(RestClient).to receive(:get).with(
        'https://api.exchangeratesapi.io/latest',
        params: { base: 'EUR' }
      )

      subject.convert('EUR', 'USD', 100)
    end

    it 'raises if Api is not avaialble' do
      allow(RestClient).to receive(:get).and_raise(RestClient::Exception)

      expect { subject.convert('EUR', 'USD', 100) }.to raise_error(
        Converter::ApiError
      )
    end

    it 'raises if Api returns error' do
      allow(RestClient).to receive(:get).and_raise(
        RestClient::ExceptionWithResponse
      )

      expect { subject.convert('EUR', 'USD', 100) }.to raise_error(
        Converter::ApiError
      )
    end

    it 'reports api response to log' do
      expect(logger).to receive(:debug).with(
        'exchangeratesapi.io response: {"base":"EUR","rates":{"USD":1.1}}'
      )

      subject.convert('EUR', 'USD', 100)
    end

    it 'raises if response is not JSON' do
      allow(RestClient).to receive(:get).and_return(
        double(body: 'INVALID_RESPONSE')
      )

      expect { subject.convert('EUR', 'USD', 100) }.to raise_error(
        Converter::ApiError
      )
    end

    it 'raises if response does not contain rates' do
      allow(RestClient).to receive(:get).and_return(
        double(body: '{"base":"EUR"')
      )

      expect { subject.convert('EUR', 'USD', 100) }.to raise_error(
        Converter::ApiError
      )
    end

    it 'raises InvalidParameter if conversion target not found' do
      expect { subject.convert('EUR', 'INVALID', 100) }.to raise_error(
        Converter::InvalidParameter
      )
    end
  end
end
