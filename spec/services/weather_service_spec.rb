require 'rails_helper'

RSpec.describe WeatherService do
  let(:valid_params) do
    {
      street_address: '123 Main St',
      city: 'Portland',
      state: 'OR',
      zip: '12345'
    }
  end

  let(:latitude) { 45.5230 }
  let(:longitude) { -122.6764 }

  let(:weather_data) do
    {
      current: { temp: 72.5, weather: [{ description: 'Sunny' }] },
      daily: [{ temp: { max: 75, min: 65 } }]
    }
  end

  let(:api_client_class) { class_double(OpenWeatherMapClient).as_stubbed_const }
  let(:api_client_instance) { instance_double(OpenWeatherMapClient) }
  let(:geocoder) { class_double(Geocoder).as_stubbed_const }

  let(:service) { described_class.new(valid_params) }

  before do
    allow(geocoder).to receive(:coordinates).with(anything).and_return([latitude, longitude])
    allow(api_client_class).to receive(:new).and_return(api_client_instance)
  end

  describe '#fetch_weather' do
    context 'when API request is successful' do
      before do
        allow(api_client_instance).to receive(:current_weather_with_forecast)
          .with(latitude, longitude)
          .and_return(weather_data)
      end

      after(:all) do
        Rails.cache.clear
      end

      it 'returns weather data' do
        result = service.fetch_weather
        expect(result[:weather]).to eq(weather_data)
        expect(result[:cache_hit]).to be false
      end

      it 'caches the result' do
        service.fetch_weather
        expect(Rails.cache.read("weather_for_#{valid_params[:zip]}")).to eq(weather_data)
      end

      it 'returns cached data on subsequent calls' do
        result = service.fetch_weather
        expect(result[:cache_hit]).to be true
      end
    end

    context 'when API request fails' do
      before do
        allow(api_client_instance).to receive(:current_weather_with_forecast)
          .with(latitude, longitude)
          .and_raise(StandardError.new('API Error'))
      end

      it 'bubbles the error to the controller' do
        expect { service.fetch_weather }.to raise_error(StandardError, 'API Error')
      end
    end
  end
end
