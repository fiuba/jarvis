require_relative './command.rb'
require 'restclient'

class RestCommand < Command

	attr_accessor :url

	def self.for_url(url)
		cmd = RestCommand.new
		cmd.url = url
		cmd
	end

	def execute
		self.output = RestClient.get( url, { :api_key => ENV['ALFRED_API_KEY'] })
		true
	end

end