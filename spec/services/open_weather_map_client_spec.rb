require 'rails_helper'
require 'vcr'
require 'webmock'

RSpec.describe OpenWeatherMapClient, :vcr do
  let(:client) { described_class.new }
  let(:lat) { 45.5230 }
  let(:lon) { -122.6764 }

  describe '#current_weather_with_forecast' do
    context 'when the request is successful' do
      it 'returns the parsed response' do
        response = client.current_weather_with_forecast(lat, lon)
        expect(response).to include('current', 'daily')
      end
    end

    context 'when the API key is invalid' do
      before do
        ENV['OPEN_WEATHER_MAP_API_KEY'] = 'invalid_api_key'
      end

      it 'raises an InvalidApiKeyError' do
        expect do
          client.current_weather_with_forecast(lat, lon)
        end.to raise_error(OpenWeatherMapClient::InvalidApiKeyError)
      end
    end

    context 'when the rate limit is exceeded' do
      before do
        stub_request(:get, /api.openweathermap.org/)
          .to_return(status: 429, body: '{"message":"You have exceeded the rate limit"}')
      end

      it 'raises a RateLimitExceededError' do
        expect do
          client.current_weather_with_forecast(lat, lon)
        end.to raise_error(OpenWeatherMapClient::RateLimitExceededError)
      end
    end

    context 'when there is a timeout' do
      before do
        stub_request(:get, /api.openweathermap.org/)
          .to_timeout
      end

      it 'raises a TimeoutError' do
        allow(OpenWeatherMapClient).to receive(:get).and_raise(Net::OpenTimeout)
        expect { client.current_weather_with_forecast(lat, lon) }.to raise_error(OpenWeatherMapClient::TimeoutError)
      end
    end

    context 'when there is an unknown error' do
      before do
        stub_request(:get, /api.openweathermap.org/)
          .to_return(status: 500)
      end
      it 'raises an OpenWeatherMapError' do
        expect do
          client.current_weather_with_forecast(lat, lon)
        end.to raise_error(OpenWeatherMapClient::OpenWeatherMapError)
      end
    end
  end
end
