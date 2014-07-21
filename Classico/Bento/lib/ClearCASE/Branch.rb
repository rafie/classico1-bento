
require_relative 'Common.rb'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Branch
#	include Bento::Class

	attr_reader :name
	
	def is(name, *opt)
		fix_name(name)
	end

	def create(name, *opt, root_vob: nil)
		fix_name(name)
		@root_vob = root_vob

		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

		mkbrtype = System.command("cleartool mkbrtype -nc #{@name}@/#{@admin_vob}")
		raise "Cannot create branch #{name}" if mkbrtype.failed?
	end

	def fix_name(name)
		@name = name
		@name += "_br" if ! @name.end_with?("_br")
	end

	#------------------------------------------------------------------------------------------

#	def Branch.admin_vob
#		begin
#			cview = ClearCase.CurrentView
#			admin_vob = cview.admin_vob
#		rescue
#			admin_vob = DEFAULT_ADMIN_VOB
#		end
#		
#		admin_vob
#	end

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

#		return @admin_vob if defined?(@admin_vob)
#
#		begin
#			cview = ClearCASE.CurrentView
#			@admin_vob = cview.admin_vob
#		rescue
#			@admin_vob = DEFAULT_ADMIN_VOB
#		end
#		
#		@admin_vob = DEFAULT_ADMIN_VOB if ! defined?(@admin_vob)
#		@admin_vob
	end

	def exists?
		desc = System.command("cleartool describe brtype:#{@name}@/#{admin_vob}")
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
