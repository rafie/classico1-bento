
require 'Bento'

ne = Nexp("lots.ne")
(ne[:lots]%"nbu.mcu")[0] << "jojo"

lots = ne[0][:lots]
x = lots/:lot
y = x%"nbu.mcu"
byebug
a = ne.cadr
z = 1
