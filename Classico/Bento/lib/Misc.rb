
require 'Digest'
require 'rufus/mnemo'
require 'zip'

module Bento

#----------------------------------------------------------------------------------------------

def self.rand_name
	Rufus::Mnemo.from_i(rand(16**5))
end

#----------------------------------------------------------------------------------------------

def self.tempfile(text)
	file = Tempfile.new('temp')
	path = file.path
	file.write(text)
	file.close
	path
end

#----------------------------------------------------------------------------------------------

def self.unzip(zipfile, destdir = ".")
	Zip::File.open(zipfile) do |zip|
		zip.each do |file|
			path = File.join(destdir, file.name)
			FileUtils.mkdir_p(File.dirname(path))
			zip.extract(file, path) unless File.exist?(path)
		end
	end
end

#----------------------------------------------------------------------------------------------

def self.md5file(file)
	Digest::MD5.file(file).hexdigest
end

def self.md5dir(dir)
	files = Dir["#{dir}/**/*"].reject { |f| File.directory?(f) }
	a = files.map { |file| Digest::MD5.file(file).hexdigest }
	Digest::MD5.hexdigest(a.join)
end

#----------------------------------------------------------------------------------------------

end # module Bento
