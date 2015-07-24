
require 'logger'

module Bento

#---------------------------------------------------------------------------------------------- 

module Log
	$logger = nil
	$log_stream = $stdout
	
	def debug(progname = nil, &block)
		logger.debug(progname, &block)
	end

	def info(progname = nil, &block)
		logger.info(progname, &block)
	end

	def warn(progname = nil, &block)
		logger.warn(progname, &block)
	end

	def error(progname = nil, *args, &block)
		text = Log.get_message(progname, &block)
		puts "Error: " + text
		logger.add(Logger::ERROR, text, &block)
	end

	def fatal(progname = nil, &block)
		text = Log.get_message(progname, &block)
		logger.add(Logger::FATAL, text, nil)
		raise RuntimeError.new(text)
	end

	def Log.get_message(text, &block)
		text = yield if block_given?
		text
	end

	def Log.to=(io)
		$log_stream = io
	end

	def logger
		return $logger if $logger

		$logger = Logger.new($log_stream)
		$logger.formatter = proc do |severity, datetime, progname, msg|
			when_s = datetime.strftime('%Y-%m-%d %H:%M:%S')
			"#{when_s} #{severity} #{msg}\n"
		end
		$logger
	end
end

#---------------------------------------------------------------------------------------------- 

end # Bento

#---------------------------------------------------------------------------------------------- 

class Object
	include Bento::Log
end

