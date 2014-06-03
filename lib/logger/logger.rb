require 'le'

module Jarvis
  def self.normalize( log_level )
    return log_level.to_i unless log_level.nil?
    Logger::INFO 
  end

  def self.logger 
    logger = Le.new(ENV['LOGENTRIES_TOKEN'], :local => true )
    logger.level = normalize(ENV['LOG_LEVEL'])
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}:#{severity} #{msg}"
    end
    logger
  end
end
