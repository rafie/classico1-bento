
require 'rufus/mnemo'
require 'zip'

module Bento

#----------------------------------------------------------------------------------------------

def Bento.rand_name
	Rufus::Mnemo.from_i(rand(16**5))
end

#----------------------------------------------------------------------------------------------

def Bento.tempfile(text)
	file = Tempfile.new('temp')
	path = file.path
	file.write(text)
	file.close
	path
end

#----------------------------------------------------------------------------------------------

def Bento.unzip(zipfile, destdir = ".")
	Zip::File.open(zipfile) do |zip|
		zip.each do |file|
			path = File.join(destdir, file.name)
			FileUtils.mkdir_p(File.dirname(path))
			zip.extract(file, path) unless File.exist?(path)
		end
	end
end

#----------------------------------------------------------------------------------------------

end # module Bento
