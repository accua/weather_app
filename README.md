# Weather Forecast Sample Application

## Overview

This Rails application provides users with current weather conditions and a 3-day forecast for a given address. It integrates with the OpenWeatherMap API and Geocoder to fetch real-time weather data.

## Features

- Address-based weather lookup
- Current weather conditions display
- 3-day weather forecast
- Caching mechanism to reduce API calls
- Responsive design using Tailwind CSS
- Hotwire for a modern rails interactive experience

## Prerequisites

- Ruby 3.3.0 or higher
- Rails 7.1.3.4 or higher
- PostgreSQL

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/accua/weather_app.git
   cd weather_app
   ```
   
2. Install Dependencies
   ```bash
   bundle install
   ```

3. Setup the Database
   ```bash
   rails db:setup
   ```

4. Create a .env file in the app root and add your OpenWeatherMap API key:
   ```ruby
   OPEN_WEATHER_MAP_API_KEY=your_api_key_here
   ```

5. Start Rails server
   ```bash
   rails s
   ```

6. Navigate to `localhost:3000` in the browser

## Running Specs

```bash
bundle exec rspec
```

## OpenWeatherMap API Integration
This application integrates with the [OpenWeatherMap](https://openweathermap.org/) API. You'll need to sign up for a free API key to use this application.
  
