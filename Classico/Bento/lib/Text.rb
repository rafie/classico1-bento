
module Bento

module Text

#----------------------------------------------------------------------------------------------

def self.compact(s)
	a1 = s.lines.keep_if {|x| x != "\n"}
	s2 = a1.map { |s| s.gsub(/[ \t]+/, " ") }
	s2.join
end

#----------------------------------------------------------------------------------------------

def self.indent(s)
	lines = s.lines
	fragments = lines.map {|s| s.split(" ")}
	n = fragments.map {|f| f.length}.max
	lengths = fragments.map {|line| line.map {|f| f.length}}
	columns = []
	for i in 0..n-1 do
		columns << lengths.map {|x| i < x.size ? x[i] : 0}.max
	end
	s = ""
	fragments.each do |line|
		for i in 0..line.length-1 do
			s += (i == 0 ? "" : " ") + sprintf("%-#{columns[i]}s", line[i])
		end
		s = s.strip + "\n"
	end
	s
end

#----------------------------------------------------------------------------------------------

end # Text

end # Bento
