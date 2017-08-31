# Run via rack server
require 'bundler/setup'

require 'rack/ssl'
use Rack::SSL

use Rack::Deflater

require 'volt/server'
run Volt::Server.new.app
