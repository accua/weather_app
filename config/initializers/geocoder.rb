Geocoder.configure(
  timeout: 3,
  lookup: :nominatim,
  http_headers: {
    'User-Agent' => 'WeatherFetchingApp/1.0',
    'Referer' => 'http://localhost:3000'
  }
)
