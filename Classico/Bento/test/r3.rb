
require 'Bento'
# require 'Bento/lib/ClearCASE'

begin
#	packed = ClearCASE.PackedVOB("test.vob.zip")
#	vob = packed.unpack(".jojo1")

##	vob = ClearCASE::VOB.create(".jojo1", file: "test.vob.zip")
##	vob = ClearCASE.VOB(".jojo1")
#	vob.pack("jojo1.vob.zip")
	
	vob = ClearCASE::VOB.create('', file: "test.vob.zip")
	vob.remove!

#	v1 = ClearCASE::View.create("/#{@vob.name}")
#	v1 = ClearCASE::View.create("", root_vob: @vob)
ensure
#	vob.remove! rescue ''
#	view.remove
end
