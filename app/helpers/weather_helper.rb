module WeatherHelper
  def weather_icon(icon_code, classes)
    icon_map = {
      '01d' => 'sun',
      '01n' => 'moon',
      '02d' => 'cloud-sun',
      '02n' => 'cloud-moon',
      '03d' => 'cloud',
      '03n' => 'cloud',
      '04d' => 'clouds',
      '04n' => 'clouds',
      '09d' => 'cloud-showers-heavy',
      '09n' => 'cloud-showers-heavy',
      '10d' => 'cloud-sun-rain',
      '10n' => 'cloud-moon-rain',
      '11d' => 'bolt',
      '11n' => 'bolt',
      '13d' => 'snowflake',
      '13n' => 'snowflake',
      '50d' => 'smog',
      '50n' => 'smog'
    }

    icon = icon_map[icon_code] || 'question'
    "<i class='fas fa-#{icon} #{classes}'></i>".html_safe
  end
end
