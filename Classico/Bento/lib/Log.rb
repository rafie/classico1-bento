
require 'logger'

module Bento

#---------------------------------------------------------------------------------------------- 

class Log
	@@logger = nil
	@@stream = $stdout
	
	def self.debug(progname = nil, &block)
		logger.debug(progname, &block)
	end

	def self.info(progname = nil, &block)
		logger.info(progname, &block)
	end

	def self.warn(progname = nil, &block)
		logger.warn(progname, &block)
	end

	def self.error(progname = nil, &block)
		logger.error(progname, &block)
	end

	def self.fatal(progname = nil, &block)
		logger.fatal(progname, &block)
	end

	def self.to=(io)
		@@stream = io
	end

	def self.begin
		self.info "-" * 80
	end

	def self.logger
		return @@logger if @@logger

		@@logger = Logger.new(@@stream)
		@@logger.formatter = proc do |severity, datetime, progname, msg|
			when_s = datetime.strftime('%Y-%m-%d %H:%M:%S')
			"#{when_s} #{severity} #{msg}\n"
		end
		@@logger
	end
end

#---------------------------------------------------------------------------------------------- 

end # Bento
