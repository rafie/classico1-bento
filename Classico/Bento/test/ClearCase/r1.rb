
require 'Bento.rb'
require 'Bento/lib/ClearCASE.rb'

require 'byebug'

byebug
# vob = ClearCASE.PackedVOB('', :jazz, file: 'H:\prj\github\confetti1\Confetti\test\confetti.test.vob.zip')
# vob.unpack('', :jazz)
vob = ClearCASE.VOB('binudiya')
vob.unmount
vob.unregister
