
module Bento

#----------------------------------------------------------------------------------------------

def self.tempfile(text)
	file = Tempfile.new('temp')
	path = file.path
	file.write(text)
	file.close
	path
end

#----------------------------------------------------------------------------------------------

def self.fread(file)
	IO.read(file)
end

#----------------------------------------------------------------------------------------------

def self.fwrite(file, text)
	IO.write(file, text)
end

#----------------------------------------------------------------------------------------------

end # module Bento

#----------------------------------------------------------------------------------------------
 
class Pathname
	def /(x)
		self + x
	end
	
	def to_str
		to_s
	end

	def to_win
		Pathname.new(to_s.gsub(/\//, '\\'))
	end

	def to_ux
		Pathname.new(to_s.gsub(/\\/, '/'))
	end
	
	def newext(ext)
		dirname/(basename(extname).to_s + ext)
	end
end

#----------------------------------------------------------------------------------------------
 
class Dir
	def Dir.empty?(dir)
		Dir.exist?(dir) && (Dir.chdir(dir){ Dir.glob("{*,.*}") } - [".",".."]).empty?
	end
end

#----------------------------------------------------------------------------------------------
