
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Configspec
	include Bento::Class

	constructors :is, :from_s
	members :vobs_cfg, :root_vob, :branch, :tag, :checks

	attr_reader :vobs_cfg, :root_vob, :branch, :tag, :checks

	@@nobranch_t = <<-END
element * CHECKEDOUT

<%= core %>
END

	@@branch_t = <<-END
element * CHECKEDOUT

element * .../<%= branch %>/LATEST
mkbranch <%= branch %>
<%= core %>
end mkbranch
END

	@@core_t = <<-END
<% @checks.reverse.each do |check| %>
element * <%= check %>
<% end %>

<% if !@tag.empty? %>
element * <%= tag %>
<% end %>

<% @vobs_cfg.keys.each do |vob| %>
element <%= root_vob_prefix %><%= vob %>/... <%= vobs_cfg[vob] %>
<% end %>

element * /main/0
END

	# vobs_cfg: vobs_cfg[vobname]=tag
	def is(vobs_cfg: nil, root_vob: nil, branch: nil, tag: nil, checks: nil)
		@vobs_cfg = vobs_cfg == nil ? {} : vobs_cfg
		@root_vob = root_vob.to_s
		@branch = branch.to_s
		@tag = tag.to_s
		@checks = checks == nil ? [] : checks
	end

	# this will parse a trivial configspec (i.e. element specs)
	# don't expact magic here
	def from_s(text)
		@root_vob = ""
		@branch = ""
		@tag = ""
		@checks = []
		@vobs_cfg = {}

		text.lines.each do |line|
			next if ! (line =~ /^\s*element\s+(.*)/)
			e = $1.split(/\s+/)
			e[0] =~ /[\/\\]([^\/\\]+)[\/\\]\.\.\./
			vob = $1
			tag = e[1]
			
			next if !vob || !tag
			@vobs_cfg[vob] = tag
		end
	end

	#-----------------------------------------------------------------------------------------

	def to_s
		if @branch.empty?
			s = Bento.mold(@@nobranch_t, binding)
		else
			s = Bento.mold(@@branch_t, binding)
		end
		Configspec.indent(s)
	end
	
	def core
		Bento.mold(@@core_t, binding)
	end

	def root_vob_prefix
		"/" + @root_vob
	end
	
	def self.compact(s)
		a1 = s.lines.keep_if {|x| x != "\n"}
		s2 = a1.map { |s| s.gsub(/[ \t]+/, " ") }
		s2.join
	end

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
end

#----------------------------------------------------------------------------------------------

end # module ClearCASE
