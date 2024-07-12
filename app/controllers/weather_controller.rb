class WeatherController < ApplicationController
  include AddressFormattable

  def index; end

  def forecast
    @address_form = AddressForm.new(address_params)

    if @address_form.valid?
      fetch_and_process_weather
    else
      handle_invalid_address_form
    end

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('weather_results', partial: 'weather/display'),
          turbo_stream.update('flash', partial: 'weather/flash')
        ]
      end
    end
  end

  private

  def fetch_and_process_weather
    result = WeatherService.new(address_params).fetch_weather
    @weather = result[:weather]
    @cache_hit = result[:cache_hit]

    if @weather
      @address = full_address
    else
      flash.now[:error] =
        'There was an issue retrieving weather for this address. It may be malformed. Please try again.'
    end
  rescue OpenWeatherMapClient::OpenWeatherMapError => e
    handle_weather_error(e)
  rescue StandardError => e
    handle_unexpected_error(e)
  end

  def handle_invalid_address_form
    flash.now[:error] = @address_form.errors.full_messages.join(', ')
  end

  def handle_weather_error(error)
    Rails.logger.error("OpenWeatherMapError: #{error.message}")
    flash.now[:error] = 'An error occurred while fetching the weather. Please try again later.'
    @weather = nil
    @cache_hit = false
  end

  def handle_unexpected_error(error)
    Rails.logger.error("Unexpected error attempting to fetch forecast: #{error.class} - #{error.message}")
    flash.now[:error] = 'An unexpected error occurred. Please try again.'
    @weather = nil
    @cache_hit = false
  end

  def address_params
    params.permit(:street_address, :city, :state, :zip)
  end
end
