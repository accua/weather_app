class WeatherService
  include AddressFormattable

  def initialize(address_params)
    @address_params = address_params
  end

  attr_reader :address_params

  def fetch_weather
    cached_weather = Rails.cache.read("weather_for_#{address_params[:zip]}")

    return { weather: cached_weather, cache_hit: true } if cached_weather

    coordinates = Geocoder.coordinates(full_address)
    return { weather: nil, cache_hit: false } if coordinates.blank?

    weather_data = OpenWeatherMapClient.new.current_weather_with_forecast(coordinates[0], coordinates[1])
    Rails.cache.write("weather_for_#{address_params[:zip]}", weather_data, expires_in: 30.minutes)

    { weather: weather_data, cache_hit: false }
  end
end
