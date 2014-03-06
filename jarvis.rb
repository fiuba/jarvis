JARVIS_ENV = ENV['JARVIS_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, JARVIS_ENV)

require 'dotenv'
Dotenv.load ".env.#{JARVIS_ENV}", '.env' if defined?(Dotenv)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'corrector_app'

CorrectorApp.new.run
