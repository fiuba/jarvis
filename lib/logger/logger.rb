require 'le'

module Jarvis
  def self.logger 
    logger = Le.new(ENV['LOGENTRIES_TOKEN'], :local => true )
    logger.level = ENV['LOG_LEVEL'] || Logger::DEBUG
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}:#{severity} #{msg}"
    end
    logger
  end
end
