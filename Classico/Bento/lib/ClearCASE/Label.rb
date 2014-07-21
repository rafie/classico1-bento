
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class LabelType
	attr_reader :name

	def is(name, *opt, root_vob: nil)
		@name = name
		@root_vob = root_vob
		@admin_vob = @root_vob ? @root_vob : DEFAULT_ADMIN_VOB
	end

	def create(name, *opt, root_vob: nil)
		is(name, *opt, root_vob: root_vob)

		mklbtype = System.command("cleartool mklbtype -nc #{@name}@/#{@admin_vob}")
		raise "Cannot create label #{name}" if mklbtype.failed?
	end

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB
#		@admin_vob = DEFAULT_ADMIN_VOB if ! defined?(@admin_vob)
	end

	def exists?
		System.command("cleartool describe lbtype:#{@name}@/#{admin_vob}").ok?
	end

	#-------------------------------------------------------------------------------------------

	def self.is(*args)
		x = self.new; x.send(:is, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end
	
	private :is, :create
	private_class_method :new

end # LabelType

def self.Label(*args)
	x = ClearCASE::Label.send(:new); x.send(:is, *args); x
end

#----------------------------------------------------------------------------------------------

class LabelTypes

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield ClearCASE.LabelType(name) }
	end

end # LabelTypes

#----------------------------------------------------------------------------------------------

end # module ClearCASE
