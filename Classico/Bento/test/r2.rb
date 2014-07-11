
require 'Bento'

vob = ClearCASE::VOB.unpack('', :jazz, file: 'test.vob.zip')
view = ClearCASE::View.create(ENV['USERNAME'] + '_' + Bento.rand_name, root_vob: vob.name)
# vob = ClearCASE::VOB.new('.bikurigi')
# view = ClearCASE::View.new('rafie_bikomene', root_vob: vob.name)
view.remove!
vob.remove!
