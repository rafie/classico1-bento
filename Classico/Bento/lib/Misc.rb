
require 'Digest'
require 'erb'
require 'rufus/mnemo'
require 'zip'

module Bento

#----------------------------------------------------------------------------------------------

def self.rand_name
	Rufus::Mnemo.from_i(rand(16**5))
end

#----------------------------------------------------------------------------------------------

def self.nowstr
	Time.now.strftime("%y%m%d-%H%M%S%L")
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

#----------------------------------------------------------------------------------------------

def self.md5dir(dir)
	files = Dir["#{dir}/**/*"].reject { |f| File.directory?(f) }
	a = files.map { |file| Digest::MD5.file(file).hexdigest }
	Digest::MD5.hexdigest(a.join)
end

#----------------------------------------------------------------------------------------------

def self.mold(erb_template, binding_)
	ERB.new(erb_template, 0, "-").result(binding_)
end

#----------------------------------------------------------------------------------------------

end # module Bento
