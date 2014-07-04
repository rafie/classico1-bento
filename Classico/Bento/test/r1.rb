
require 'Bento.rb'
require 'Bento/lib/ClearCASE.rb'

require 'byebug'

byebug
# vob = ClearCASE::PackedVOB.new('', :jazz, file: 'H:\prj\github\confetti1\Confetti\test\confetti.test.vob.zip')
# vob.unpack('', :jazz)
vob = ClearCASE::VOB.new('binudiya')
vob.unmount rescue ''
vob.unregister
