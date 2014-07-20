
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class View             
	include Bento::Class

	attr_reader :name
	attr_writer :configspec

	def def(name, *opt, root_vob: nil)
		@name = name
		@root_vob = root_vob if root_vob != nil

		fix_name
	end

	def create(name, *opt, root_vob: nil, configspec: nil)
		@name = name
		@raw_name = opt.include? :raw
		fix_name

		@root_vob = root_vob if root_vob != nil

		region = DEFAULT_WIN_REGION
		host = System.hostname
		stg = LocalStorageLocation.new
		local_stg = "#{stg.local_stg}\\#{@name}.vws"
		global_stg = "#{stg.global_stg}\\#{@name}.vws"

		mkview_cmd = "cleartool mkview -tag #{@name} -tmode unix -region #{region} -shareable_dos " + 
			"-host #{host} -hpath #{local_stg} -gpath #{global_stg} #{local_stg}"
		mkview = System.command(mkview_cmd)	
		raise "failed to create view #{@name}" if mkview.failed?

		self.configspec = configspec if configspec

		ClearCASE::Explorer.add_view_shortcut(@name) rescue ''
	end

	#------------------------------------------------------------------------------------------

	def exists?
		lsview = System.commandx("cleartool lsview -short #{name}", :nolog)
		return lsview.ok?
	end

	# type = :dynamic/:snapshot

	def type
		if !@type
			@type = :dynamic			
			lsview = System.commandx("cleartool lsview -long #{name}", :nolog)
			lsview.out.lines.each do |line|
				if line =~ /^View attributes: (.*)/
					snap = $1
					#only snapshot views return the "View attributes" line.
					@type = ($snap =~ /.*snapshot.*/) ? :dynamic : :snapshot
				end
			end
		end
		
		return @type
	end

	def path
		"M:/#{name}" + (defined?(@root_vob) ? "/#{@root_vob}" : "")
	end

	def root_vob
		return VOB.new(@root_vob) if @root_vob
		nil
	end

	def configspec=(spec)
		setcs_cmd = "cleartool setcs -tag #{@name} " + Bento.tempfile(spec)
		setcs = System.commandx(setcs_cmd, what: "set configspec for view #{@name}")
	end

	#------------------------------------------------------------------------------------------

	def elements(names)
		Elements.new(names.map { |e| path + '/' + e })
	end

	def checkout(names)
		elements(names).checkout
	end

	#------------------------------------------------------------------------------------------

	# finds all checked out files in view
	
	def checkouts
		lsco = System.command("pushd M:\\#{@name} & cleartool lsco -avobs -cview -short")
		raise "checked-out elements query failed for viewe #{@name}" if lsco.out0 =~ /Error/
		ClearCASE::Elements.new(lsco.out.lines)
	end
	
	# finds all files on a given branch in view

	def on_branch(branch)
		branch_name = branch.is_a?(ClearCASE::Branch) ? branch.name : Branch.new(branch).name
		find = System.command("pushd M:\\#{@name} & cleartool find -element brtype(#{branch_name}) -nxname -avobs -visible -print")
		raise "elements on branch query failed for view {@name}" if find.failed?
		ClearCASE::Elements.new(find.out.lines)
	end

	#------------------------------------------------------------------------------------------

	def remove!
		# endview = System.command("cleartool endview -server #{@name}")
		rmview = System.command("cleartool rmview -tag #{@name}")
	end

	#------------------------------------------------------------------------------------------

	def fix_name
		if @name =~ /^([^\\]*)\/(.*)/
			@name = $1
			raise "conflicting root_vob specifications: #{@root_vob} and #{$2}" if defined?(@root_vob) && @root_vob != $2
			@root_vob = $2
		else
			@root_vob = '' if !defined?(@root_vob)
		end
		@name = Bento.rand_name if @name.empty?
		@name = System.user.downcase + "_" + @name if !@raw_name
	end

	#------------------------------------------------------------------------------------------

	def self.def(*args)
		x = self.new; x.send(:def, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end
	
	private :fix_name

	private :def, :create
	private_class_method :new

end # class View

def self.View(*args)
	x = ClearCASE::View.send(:new); x.send(:def, *args); x
end

#----------------------------------------------------------------------------------------------

class CurrentView < View

	def def(*opt, root_vob: nil)
		name = System.commandx("cleartool pwv -sh", :nolog).out0
		raise "Cannot determine current view" if name == "** NONE **"
		super(name, *opt, root_vob: root_vob)
	end

	def current_vob
		view, vob, path = ClearCASE::Element.parse(Dir.pwd)
		raise "No current VOB" if vob.empty?
		VOB.new(vob)
	end

	private :def
	private_class_method :new

end # class CurrentView

def self.CurrentView(*args)
	x = ClearCASE::CurrentView.send(:new); x.send(:def, *args); x
end

#----------------------------------------------------------------------------------------------

class LocalView
end

#----------------------------------------------------------------------------------------------

class RemoteView
end

#----------------------------------------------------------------------------------------------

end # module ClearCASE
