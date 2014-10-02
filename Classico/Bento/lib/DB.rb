
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
		
		@temp = false
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

	def rows(*args)
		execute(*args)
	end
	
	def [](*args)
		rows(*args)
	end

	def <<(*args)
		@db.execute_batch(*args)
		self
	end

	def single(*args)
		Result.new(@db.get_first_row(*args))
	end
	
	alias_method :one, :single
	alias_method :row, :single

	def val(*args)
		one(*args)[0]
	end

	def insert(table, cols, *values)
		# values_s = values.map {|x| x.is_a?(Numeric) ? x.to_s : "'#{x.to_s}'" }
		values_s = values.map{|x| "?" }.join(",")
		cols_s = cols.map {|x| x.to_s}.join(",")
		insert = "insert into #{table.to_s} (#{cols_s}) values (#{values_s});"
		execute(insert, *values)
		@inserted_table = table.to_s
		begin
			@inserted_id = single("select last_insert_rowid() as id;")[:id]
		rescue; end
	end

	def inserted
		one("select * from #{@inserted_table} where id=?", @inserted_id)
	end

	#-------------------------------------------------------------------------------------------

	def transaction
		begin
			@db.transaction
			yield
			@db.commit
		rescue Exception => x
			@db.rollback
			raise x
    	end
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

	class Result
		def initialize(result)
			@result = result
		end
		
		def [](x)
			@result[x.is_a?(Fixnum) ? x : x.to_s]
		end

		def !()
			@result == nil
		end
	end			

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

		def ord(i)
			@results[i]
		end

		def each
			@results.each { |x| yield Results.new(x) }
		end

		def count
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
