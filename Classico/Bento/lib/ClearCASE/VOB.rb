
require_relative 'Common'
require 'fileutils'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class VOB
	include Bento::Class

	attr_reader :name

	def def(name, *opt)
		init_flags [:jazz], opt
		@name = VOB.fix_name(name)
	end

	def create(name, *opt, file: nil)
		init_flags [:jazz], opt
		opt.delete(:jazz) # don't pass it on

		@name = VOB.fix_name(name)
		@jazz = true if @name.empty?
		@name = VOB.jazz_name(@name)

		if !file
			global_vbs = VOB.global_vbs(@name)
			mkvob = System.command("cleartool mkvob -nc -tag #{tag} #{global_vbs}")
			raise "cannot create VOB #{@name}" if mkvob.failed?
			return
		end

		@file = file

		ClearCASE.PackedVOB(@file).unpack(@name)
	end
	
	#-------------------------------------------------------------------------------------------

	def tag
		"\\#{@name}"
	end
	
	def uuid
		query if !defined?(@uuid); @uuid
	end

	def region
		query if !defined?(@region); @region
	end

	def local_vbs
		query if !defined?(@local_vbs); @local_vbs
	end

	def global_vbs
		query if !defined?(@global_vbs); @global_vbs
	end

	def exist?
		System.command("cleartool lsvob -long #{tag}").ok?
	end

	def mounted?
		query if !defined?(@mounted); @mounted
	end

	def locked?
		lslock = System.command("cleartool lslock -short #{tag}")
		raise "cannot query lock information about VOB #{@name}" if lslock.failed?
		lslock.out0 == tag
	end

	def has_branch?(brtype)
		System.command("cleartool lstype -sh -local brtype:#{brtype}@/#{@name}", :nolog).ok?
	end

	#-------------------------------------------------------------------------------------------

	def self.fix_name(name)
		name =~ /^[\/\\]/ ? name[1..-1] : name
	end

	def self.jazz_name(name)
		name = "." + (name.empty? ? "" : name + "_") + Bento.rand_name
	end

	def self.global_vbs(name)
		storage = ClearCASE::LocalStorageLocation.new
		"#{storage.global_stg}\\.vobs\\#{name}.vbs"
	end
	
	def self.local_vbs(name)
		storage = ClearCASE::LocalStorageLocation.new
		"#{storage.local_stg}\\.vobs\\#{name}.vbs"
	end

	#-------------------------------------------------------------------------------------------

	def pack(file)
		PackedVOB::create(@name, file: file)
	end

	#-------------------------------------------------------------------------------------------

	def mount
		mnt = System.command("cleartool mount #{tag}")
		raise "cannot mount VOB #{@name}" if mnt.failed? && !mnt.err0 =~ /is already mounted/
	end
	
	def unmount
		umnt = System.command("cleartool umount #{tag}")
		raise "cannot mount VOB #{@name}" if umnt.failed? && !mnt.err0 =~ /is not currently mounted/
	end

	def lock
		lock = System.command("cleartool lock vob:#{tag}")
		raise "cannot lock VOB #{@name}" if lock.failed?
	end
	
	def unlock
		unlock = System.command("cleartool unlock vob:#{tag}")
		raise "cannot unlock VOB #{@name}" if unlock.failed?
	end

	#-------------------------------------------------------------------------------------------

	def remove!
		begin
			unmount
		rescue ; end
		rmvob = System.command("cleartool rmvob -force #{global_vbs}")
		raise "cannot remove VOB #{@name}" if rmvob.failed?
	end

	#-------------------------------------------------------------------------------------------

	def register
		host = System.hostname
		local_vbs = VOB.local_vbs(@name)
		global_vbs = VOB.global_vbs(@name)
		region = DEFAULT_WIN_REGION

		mktag = System.command("cleartool mktag -vob -tag #{tag} -host #{host} -region #{region} -gpath #{global_vbs} #{local_vbs}")
		raise "cannot register VOB #{@name}: mktag failed" if mktag.failed?
		register = System.command("cleartool register -vob -host #{host} -hpath #{local_vbs} #{global_vbs}")
		if register.failed?
			System.command("cleartool rmtag -vob #{tag}")
			raise "cannot register VOB #{@name}"
		end
	end

	def unregister
		rmtag = System.command("cleartool rmtag -vob #{tag}")
		raise "cannot unregister VOB #{@name}: rmtag failed" if rmtag.failed?
		unreg = System.command("cleartool unregister -vob -uuid #{uuid}")
		raise "cannot unregister VOB #{@name}: unregister failed" if unreg.failed?
	end

	#-------------------------------------------------------------------------------------------

	def query
		lsvob = System.command("cleartool lsvob -long #{tag}")
		raise "cannot query information about VOB #{@name}" if lsvob.failed?
		lsvob.out.lines.each do |line|
			@uuid = $1 if line =~ /Vob replica uuid\: *(.*)/
			@region = $1 if line =~ /Region\: *(.*)/
			@local_vbs = $1 if line =~ /Vob server access path\: *(.*)/
			@global_vbs = $1 if line =~ /Global path\: *(.*)/
			@mounted = $1 if line =~ /Active\: *(.*)/
		end
		@mounted = @mounted == "YES"
	end

	#-------------------------------------------------------------------------------------------

	def self.def(*args)
		x = self.new; x.send(:def, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end
	
	private :query

	private :def, :create
	private_class_method :new

end # class VOB

def self.VOB(*args)
	x = ClearCASE::VOB.send(:new); x.send(:def, *args); x
end

#----------------------------------------------------------------------------------------------

class PackedVOB
	include Bento::Class
	
	def def(file, *opt)
		@file = file
	end

	def create(name, *opt, file: nil)
		file = name + ".vob.zip" if !file
		raise "cannot pack, file #{@file} exists" if File.exists?(file)
		@file = file

		vob = ClearCASE.VOB(name)
		vob.lock
		begin
			path = File.absolute_path(@file)
			Dir.chdir(vob.local_vbs) do
				zip = System.command("zip -r #{path} *")
				raise "failed to create zip file #{@file}" if zip.failed?
			end
		ensure
			vob.unlock
		end
	end

	#-------------------------------------------------------------------------------------------

	def unpack(name, *opt)
		jazz = opt.include?(:jazz)
		keep_ids = opt.include?(:keepid)

		name = VOB.jazz_name(name) if jazz

		raise "cannot unpack, file #{@file} does not exists" if !File.exists?(@file)
		raise "cannot unpack, vob #{name} exists" if VOB(name).exist?

		vbs = VOB.local_vbs(name)
		raise "cannot unpack, VOB storage dircotry #{vbs} exists" if File.exists?(vbs)
		unzip = System.command("unzip -d #{vbs} #{@file}")
		if unzip.failed?
			# FileUtils.rm_rf(vbs)
			raise "failed to unpack zip file #{@file}" 
		end

		vbs.gsub!('\\', '/')
		Dir.glob("#{vbs}/**/*") { |f| FileUtils::chmod(0666, f) }
		Dir.glob("#{vbs}/**/.[^\.]*") { |f| FileUtils::chmod(0666, f) }

		host = System.hostname
		File.open("#{vbs}/.hostname", 'w') { |f| f.puts(host) }

		if (!keep_ids)
			vob_oid = ClearCASE::UUID.new
			File.open("#{vbs}/vob_oid", 'w') { |f| f.puts(vob_oid) }
			replica_uuid = ClearCASE::UUID.new
			File.open("#{vbs}/replica_uuid", 'w') { |f| f.puts(replica_uuid) }
			fix_pool_id("#{vbs}/c/cdft/pool_id", replica_uuid, vob_oid)
			fix_pool_id("#{vbs}/d/ddft/pool_id", replica_uuid, vob_oid)
			fix_pool_id("#{vbs}/s/sdft/pool_id", replica_uuid, vob_oid)
		end

		fix_permissions(name)
		vob = VOB(name)
		vob.register
		vob.mount
		vob
	end

	#-------------------------------------------------------------------------------------------

	def fix_pool_id(file, replica_uuid, vob_oid)
		File.open(file, 'r+') { |f|
			f.gets =~ /poolkind=(.) pool_oid=([^ ]*)/
			kind = $1
			pool_oid = $2
			f.reopen(file, 'w') 
			f.puts("poolkind=#{kind} pool_oid=#{pool_oid} replica_uuid=#{replica_uuid} vob_oid=#{vob_oid}") }
	end

	def fix_permissions(vob_name)
		fix_prot = ClearCASE.utility("fix_prot.exe")
		local_vbs = VOB.global_vbs(vob_name)
		user = System.user
		domain = System.domain
		group = ClearCASE::DEFAULT_GROUP
		fix = System.command("#{fix_prot} -force -root -r -chown #{domain}\\#{user} -chgrp #{domain}\\#{group} #{local_vbs}")
	end

	#-------------------------------------------------------------------------------------------

	def self.def(*args)
		x = self.new; x.send(:def, *args); x
	end

	def self.create(*args)
		x = self.send(:new); x.send(:create, *args); x
	end
	
	private :fix_pool_id, :fix_permissions

	private :def, :create
	private_class_method :new

end # PackedVOB

def self.PackedVOB(*args)
	x = PackedVOB.send(:new); x.send(:def, *args); x
end

#----------------------------------------------------------------------------------------------

class VOBs
	include Enumerable

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |vname| yield VOB(vname) }
	end

end # class VOBs

#----------------------------------------------------------------------------------------------

end # module ClearCASE
