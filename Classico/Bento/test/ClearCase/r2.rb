
require 'Bento'

vob = ClearCASE::VOB.unpack('', :jazz, file: 'test.vob.zip')
view = ClearCASE::View.create(ENV['USERNAME'] + '_' + Bento.rand_name, root_vob: vob.name)
view.remove!
vob.remove!

# vob = ClearCASE.VOB('.bikurigi')
# view = ClearCASE.View('rafie_bikomene', root_vob: vob.name)




vob = ClearCASE::VOB.unpack('', :jazz, file: 'test.vob.zip')
view = ClearCASE::View.create(ENV['USERNAME'] + '_' + Bento.rand_name, root_vob: vob.name)
view.remove!
vob.remove!


ClearCASE:View.create_from_packed_vob('test.vob.zip')
