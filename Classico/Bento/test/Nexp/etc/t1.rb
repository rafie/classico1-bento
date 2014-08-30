
require 'Bento'
require 'byebug'

ne = Nexp("lots.ne")
lots = ne[0][:lots]
x = lots/:lot
y = x%"nbu.mcu"
byebug
a = ne.cadr
z = 1
