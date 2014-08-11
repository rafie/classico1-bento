
require_relative 'Common.rb'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Branch
	include Bento::Class

	attr_reader :name

	# consider appending admin vob to tag
	
	def is(name, *opt, tag: nil)
		fix_name(name, tag)
	end

	def create(name, *opt, root_vob: nil, tag: nil)
		fix_name(name, tag)
		@root_vob = root_vob

		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

		mkbrtype = System.command("cleartool mkbrtype -nc #{@tag}@/#{@admin_vob}")
		raise "Cannot create branch #{name} (tag=#{tag})" if mkbrtype.failed?
	end

	def fix_name(name, tag)
		name = name.to_s
		tag = "main" if name == "main" # special case
		@name = $1 if name =~ /(.*)_br$/
		@tag = !tag ? @name + "_br" : tag.to_s
	end

	#------------------------------------------------------------------------------------------

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB
	end

	def exists?
		desc = System.command("cleartool describe brtype:#{@tag}@/#{admin_vob}")
		return desc.ok?
	end

	#------------------------------------------------------------------------------------------

	def self.is(*args)
		x = self.new; x.send(:is, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end

	private :fix_name

	private :is, :create
	private_class_method :new
end # Branch

def self.Branch(*args)
	x = ClearCASE::Branch.send(:new); x.send(:is, *args); x
end

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
