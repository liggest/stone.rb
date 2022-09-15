
# require "rack/unreloader"

# Unreloader = Rack::Unreloader.new{ Sinatra::Application }
# Unreloader.require './backend/app.rb'

# run Unreloader

require "./backend/app"

run Sinatra::Application
