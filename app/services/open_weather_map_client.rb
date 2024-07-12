require 'httparty'

class OpenWeatherMapClient
  include HTTParty

  class OpenWeatherMapError < StandardError; end
  class InvalidApiKeyError < OpenWeatherMapError; end
  class RateLimitExceededError < OpenWeatherMapError; end
  class TimeoutError < OpenWeatherMapError; end

  base_uri 'https://api.openweathermap.org/data/3.0'
  default_params exclude: 'hourly,minutely', units: 'imperial'

  def current_weather_with_forecast(lat, lon)
    handle_timeouts do
      response = self.class.get("/onecall?lat=#{lat}&lon=#{lon}&appid=#{api_key}")

      handle_response(response)
    end
  end

  private

  def api_key
    ENV['OPEN_WEATHER_MAP_API_KEY']
  end

  def handle_timeouts
    yield
  rescue Net::OpenTimeout => e
    Rails.logger.error("Server timeout: #{e.message}")
    raise TimeoutError
  end

  def handle_response(response)
    case response.code
    when 200
      response.parsed_response
    when 401
      handle_api_key_error(response)
    when 429
      handle_rate_limit_error(response)
    else
      handle_unknown_error(response)
    end
  end

  def handle_api_key_error(response)
    Rails.logger.error("Issue with API key: #{response.body}")
    raise InvalidApiKeyError, "response: #{response.body}"
  end

  def handle_rate_limit_error(response)
    Rails.logger.error("Rate limit exceeded: #{response.body}")
    raise RateLimitExceededError, "response: #{response.body}"
  end

  def handle_unknown_error(response)
    Rails.logger.error("Unexpected error: #{response.body}")
    raise OpenWeatherMapError, "response: #{response.body}"
  end
end
