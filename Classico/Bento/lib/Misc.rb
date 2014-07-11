
require 'rufus/mnemo'

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

end # module Bento
