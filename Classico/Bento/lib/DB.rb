
require 'sqlite3'
require 'byebug'

module Bento

#----------------------------------------------------------------------------------------------

class DB
	attr_reader :path, :db
	@@objects = Hash.new

	include Bento::Class
	
	def init
		@db = SQLite3::Database.new(@path)
		@db.results_as_hash = true
		@cleanup = @temp

		@@objects[object_id] = self
		ObjectSpace.define_finalizer(self, proc { |id| DB.finalize(id) })
	end

	def is(*opt, path: nil, schema: nil, data: nil)
		@path = path
		@schema = schema
		@data = data
		init
	end
	
	def create(*opt, path: nil, schema: nil, data: nil)
		init_flags [:temp], opt
		
		if path == nil
			@temp = true
			@file = Tempfile.new('db')
			path = @file.path
			@file.close(unlink_now: false)
		end
		@path = path

		File.unlink(@path) rescue ''
		init

		@db.execute_batch(File.read(schema)) if schema != nil
		@db.execute_batch(File.read(data)) if data != nil
	end

	def cleanup
		@db.close
		File.unlink(@path) if @temp
#		puts "DB cleanup: " + @path if @temp
	end

	def self.finalize(id)
		db = @@objects[id]
		db.cleanup if db
	end

	#-------------------------------------------------------------------------------------------

	def execute(*args)
		Results.new(@db.execute(*args))
	end

	def [](*args)
		execute(*args)
	end

	def <<(*args)
		@db.execute_batch(*args)
		self
	end

	def single(*args)
		Results.new(@db.get_first_row(*args))
	end

	#-------------------------------------------------------------------------------------------

	def self.is(*args)
		x = self.new; x.send(:is, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end

	private :init	
	private :is, :create
	private_class_method :new

	#------------------------------------------------------------------------------------------
	
	class Results
		include Enumerable
		
		def initialize(results)
			@results = results
		end
		
		def [](x)
			if x.is_a? Fixnum
				Results.new(@results[x])
			else
				@results[x.to_s]
			end
		end
		
		def each
			@results.each { |x| yield Results.new(x) }
		end

		def count
			byebug
			!@results ? 0 : @results.count
		end

		def !()
			@results == nil
		end
	end

	#------------------------------------------------------------------------------------------

end # class DB

def self.DB(*args)
	x = DB.send(:new); x.send(:is, *args); x
end

#----------------------------------------------------------------------------------------------

class Query
	attr_reader :db

	def initialize(db, sql)
		@db = db
		@stmt = @db.execute(sql)
		@param = 0
	end

	def<<(x)
		@stmt.bind_param ++@param, x
		self
	end
	
	def exec!
		@stmt.execute
	end
end # class DB


#----------------------------------------------------------------------------------------------

end # module Bento
