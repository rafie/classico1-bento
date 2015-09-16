
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Branch
	include Bento::Class

	attr_reader :name, :tag

	constructors :is, :create
	members :name, :root_vob, :admin_vob, :tag

	# consider appending admin vob to tag

	#------------------------------------------------------------------------------------------

	def is(name, *opt, root_vob: nil, tag: nil)
		
		init_flags([:raw], opt)
		@root_vob = root_vob
		fix_name(name, tag)
		
	end

	def create(name, *opt, root_vob: nil, tag: nil)
		init_flags([:raw], opt)
		@root_vob = root_vob
		fix_name(name, tag)
		

		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

		mkbrtype = System.command("cleartool mkbrtype -nc #{@tag}@/#{@admin_vob}")
		raise "Cannot create branch #{name} (tag=#{tag})" if mkbrtype.failed?
	end

	#------------------------------------------------------------------------------------------

	def fix_name(name, tag)
		name = name.to_s
		if name == "main" # special case
			@name = tag = name
		else
			@name = name =~ /(.*)_br$/ ? $1 : name
			@name = System.user.downcase + "_" + @name if !@raw
		end
		admin_vob
		@tag = !tag ? @name + "_br" : tag.to_s
	end

	private :fix_name

	#------------------------------------------------------------------------------------------

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB
	end

	def exists?
		desc = System.command("cleartool describe brtype:#{@tag}@/#{@admin_vob}")
		return desc.ok?
	end

	#------------------------------------------------------------------------------------------

end # Branch

#----------------------------------------------------------------------------------------------

class Branches
	include Enumerable

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield ClearCASE.Branch(name) }
	end

end # Branches

#----------------------------------------------------------------------------------------------

end # module ClearCASE
