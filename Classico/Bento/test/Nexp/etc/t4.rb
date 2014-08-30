
require 'nexp'

text = <<END
(lot
	(names a b c) x y)
END

ne = Bento::Nexp.from_s(text)
pp ~ne[:lot]
pp ~ne[:lot][:names]
pp ne[:lot][:names][:a]
pp ne[:lot][:names][:b]


ne.nodes("lot/names/b")
ne["lot/names/b"] -> convert single nodes into atom
['a'].to_str == 'a'
['a','b'].to_str -> raise?
