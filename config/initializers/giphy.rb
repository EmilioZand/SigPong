ENV['GIPHY_RATING'] ||= 'g'

Giphy.configure do |config|
    config.rating = ENV['GIPHY_RATING']
  end