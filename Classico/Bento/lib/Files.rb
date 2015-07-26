
class Pathname
	def /(x)
		self + x
	end
	
	def to_str
		to_s
	end
end

class Dir
	def Dir.empty?(dir)
		Dir.exist?(dir) && (Dir.chdir(dir){ Dir.glob("{*,.*}") } - [".",".."]).empty?
	end
end
