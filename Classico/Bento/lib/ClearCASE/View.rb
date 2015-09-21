
require_relative 'Common'
require 'tmpdir'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class View
	include Bento::Class

	constructors :is, :create
	members :tag, :name, :root_vob, :raw, :nop

	attr_reader :nick, :name, :tag

	def is(nick, *opt, name: name, root_vob: nil)
		raise "View: empty name" if nick.to_s.empty? && name.to_s.empty?
		init(nick, name, root_vob, *opt)
	end

	# if name is empty, random one is generated
	# if name=x/.vob then tag=x, name=x/.vob, root_vob=.vob
	# if name=x/. then tag=x, name=x/.random, root_vob=.random
	# if name=/. then tag=random, name=random/.random, root_vob=.random
	# opt: :raw - username is not prepended to view tag

	def create(nick, *opt, name: nil, root_vob: nil, configspec: nil)
		init(nick, name, root_vob, *opt)

		region = DEFAULT_WIN_REGION
		host = System.hostname
		stg = LocalStorageLocation.new
		local_stg = "#{stg.local_stg}\\#{@tag}.vws"
		global_stg = "#{stg.global_stg}\\#{@tag}.vws"

		mkview_cmd = "cleartool mkview -tag #{@tag} -tmode unix -region #{region} -shareable_dos " + 
			"-host #{host} -hpath #{local_stg} -gpath #{global_stg} #{local_stg}"

		return if @nop
		
		mkview = System.command(mkview_cmd)	
		raise "failed to create view #{@name}" if mkview.failed?

		self.configspec = configspec if configspec

		ClearCASE::Explorer.add_view_shortcut(@tag) rescue ''
	end

	def init(nick, name, root_vob, *opt)
		init_flags([:raw, :nop, :new], opt)
		
		raise "View: conflicting name/nick" if !nick.to_s.empty? && !name.to_s.empty?

		@nick = nick.to_s
		
		if name
			@name = name
			@raw = true
		else
			@name = @nick
		end

		if root_vob == nil
			@root_vob = nil
		elsif root_vob.respond_to?(:to_s)
			@root_vob = root_vob.to_s
		elsif root_vob.respond_to?(:name)
			@root_vob = root_vob.name
		else
			raise "View: invalid root_vob specification"
		end

		fix_name
	end

	def fix_name
		if @name =~ /^([^\\]*)\/(.*)/
			@tag = $1
			raise "conflicting root_vob specifications: #{@root_vob} and #{$2}" if @root_vob && @root_vob != $2
			@root_vob = $2
			@root_vob = "." + Bento.rand_name if @root_vob == "."
		else
			@tag = @name
		end

		@tag = Bento.rand_name if @tag.strip.empty?
		@nick = @tag

		@tag = System.user.downcase + "_" + @tag if !@raw
		@name = @root_vob ? "#{@tag}/#{@root_vob}" : @tag
	end

	private :fix_name

	#------------------------------------------------------------------------------------------

	def exists?
		lsview = System.commandx("cleartool lsview -short #{tag}", :nolog)
		return lsview.ok?
	end

	# type = :dynamic/:snapshot

	def type
		if !@type
			@type = :dynamic			
			lsview = System.commandx("cleartool lsview -long #{tag}", :nolog)
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
		"M:/#{tag}" + (!@root_vob ? "": "/#{@root_vob}")
	end

	def path_w
		"M:\\#{tag}" + (!@root_vob ? "": "\\#{@root_vob}")
	end

	def root
		path
	end

	def root_vob
		@root_vob ? ClearCASE.VOB(@root_vob) : nil
	end

	def configspec=(spec)

		temp = Dir.tmpdir() 
		tmpath=temp + "/tmpconfigspec.txt"
		File.open(tmpath, 'w') {|f| f.write(spec) }
		setcs_cmd = "cleartool setcs -tag #{@tag} " + tmpath
		setcs = System.commandx(setcs_cmd) #, what: "set configspec for view #{@name}")
	end

	#------------------------------------------------------------------------------------------

	def elements(names)
		Elements.new(names.map { |e| path + '/' + e })
	end

	def checkout(names)
		elements(names).checkout
	end

	def add_files(glob)
		ClearCASE::Elements.create(glob)
	end

	#------------------------------------------------------------------------------------------

	# finds all checked out files in view
	
	def checkouts
		lsco = System.command("pushd #{path_w} & cleartool lsco -avobs -cview -short")
		raise "checked-out elements query failed for view #{@name}" if lsco.out0 =~ /Error/
		ClearCASE::Elements.new(lsco.out.lines)
	end
	
	# finds all files on a given branch in view

	def on_branch(branch)
		branch_name = branch.is_a?(ClearCASE::Branch) ? branch.name : ClearCASE.Branch(branch).name
		find = System.command("pushd #{path_w} & cleartool find -element brtype(#{branch_name}) -nxname -avobs -visible -print")
		raise "elements on branch query failed for view {@name}" if find.failed?
		ClearCASE::Elements.new(find.out.lines)
	end

	#------------------------------------------------------------------------------------------

	def start
		System.commandx("cleartool startview #{@tag}")
	end

	def stop
		System.commandx("cleartool endview -server #{@tag}")
	end

	def end
		stop
	end

	#------------------------------------------------------------------------------------------

	def remove!
		# endview = System.command("cleartool endview -server #{@tag}")
		rmview = System.command("cleartool rmview -tag #{@tag}")
	end

	#------------------------------------------------------------------------------------------

end # class View

#----------------------------------------------------------------------------------------------

class CurrentView < View

	constructors :is

	def is(*opt, root_vob: nil)
		name = System.commandx("cleartool pwv -sh", :nolog).out0
		raise "Cannot determine current view" if name == "** NONE **"
		super(name, *opt, root_vob: root_vob)
	end

	#------------------------------------------------------------------------------------------

	def current_vob
		view, vob, path = ClearCASE::Element.parse(Dir.pwd)
		raise "No current VOB" if vob.empty?
		ClearCASE.VOB(vob)
	end

end # class CurrentView

#----------------------------------------------------------------------------------------------

class LocalView
end

#----------------------------------------------------------------------------------------------

class RemoteView
end

#----------------------------------------------------------------------------------------------

end # module ClearCASE
