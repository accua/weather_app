require 'rails_helper'

RSpec.describe 'Forecasts' do
  let(:valid_params) do
    {
      street_address: '1233 Main St',
      city: 'Portland',
      state: 'OR',
      zip: '97214'
    }
  end

  let(:invalid_params) do
    {
      street_address: '',
      city: '',
      state: '',
      zip: ''
    }
  end

  describe 'GET /weather' do
    it 'returns a successful response' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /forecast', :vcr do
    context 'with valid params' do
      it 'returns a successful response' do
        get forecast_path, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'includes weather data in the response' do
        get forecast_path, params: valid_params
        expect(response.body).to include('84°F')
        expect(response.body).to include('Smoke')
      end

      it 'includes the full address in the response' do
        get forecast_path, params: valid_params
        expect(response.body).to include('1233 Main St Portland, OR 97214')
      end

      it 'returns turbo stream for turbo request' do
        get forecast_path, params: valid_params, headers: { 'Accept': 'text/vnd.turbo-stream.html' }
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include('turbo-stream')
      end
    end

    context 'with invalid params' do
      it 'includes an error message in the response' do
        get forecast_path, params: invalid_params
        expect(response.body).to include('Street address can&#39;t be blank')
        expect(response.body).to include('City can&#39;t be blank')
        expect(response.body).to include('State can&#39;t be blank')
        expect(response.body).to include('Zip can&#39;t be blank')
      end
    end

    context 'when WeatherService raises an OpenWeatherMapError' do
      before do
        allow_any_instance_of(WeatherService).to receive(:fetch_weather).and_raise(
          OpenWeatherMapClient::OpenWeatherMapError.new('API Error')
        )
      end

      it 'includes an error message in the response' do
        get forecast_path, params: valid_params
        expect(response.body).to include('An error occurred while fetching the weather')
      end
    end

    context 'when WeatherService raises an unexpected error' do
      before do
        allow_any_instance_of(WeatherService).to receive(:fetch_weather).and_raise(StandardError.new('Unexpected Error'))
      end

      it 'includes an error message in the response' do
        get forecast_path, params: valid_params
        expect(response.body).to include('An unexpected error occurred')
      end
    end

    context 'when weather data is not found' do
      before do
        allow_any_instance_of(WeatherService).to receive(:fetch_weather).and_return({ weather: nil, cache_hit: false })
      end

      it 'includes an appropriate message in the response' do
        get forecast_path, params: valid_params
        expect(response.body).to include('There was an issue retrieving weather for this address')
      end
    end
  end
end
