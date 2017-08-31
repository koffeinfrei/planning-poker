# Run via rack server
require 'bundler/setup'

require 'rack/ssl'
use Rack::SSL

require 'volt/server'
run Volt::Server.new.app
