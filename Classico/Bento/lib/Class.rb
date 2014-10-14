
# require 'byebug'

module Bento

#----------------------------------------------------------------------------------------------

module Class

	def self.included(base)
		base.extend(ClassMethods)
	end

	# if opt.include? :flag, @flag = true
	def init_flags(flags, opt)
		rest = opt.dup
		flags.each do |f|
			if rest.include? f
				instance_variable_set("@#{f}", true)
				rest.delete f
			end
		end
		return rest
	end

	def filter_flags(flags, opt)
		opt.select {|x| flags.include? x }
	end

	# if opt.include? tag, invole method tag(*args)
	def tagged_init(tag, opt, args)
		return false if !opt.include? tag
		send(tag, *args)
		return true
	end

	def assert_type(val, type)
	end

	def assert_type!(val, type)
	end

end # Class

#----------------------------------------------------------------------------------------------

module ClassMethods

	def constructors(*ctors)
		class_eval("@@ctors ||= []")
		class_eval("@@ctors += " + ctors.to_s)
	
		klass = self.name.split("::")[-2..-1].join("::")
		puts klass
		mod = eval(klass.split("::")[0..-2].join("::"))

		class_eval("private_class_method :new")

		ctors.each do |ctor|
			mod.class_eval(<<END) if ctor == :is
				def #{klass}(*args)
					x = #{klass}.send(:new)
					x.send(:is, *args)
					x
				end
END
			begin
				class_eval("private :" + ctor.to_s)
			rescue
			end

			class_eval(<<END)
				def self.#{ctor}(*args)
					x = self.send(:new)
					x.send(:#{ctor}, *args)
					x
				end
END
		end
	end
	
	def method_added(m)
		class_eval("@@ctors ||= []")
		class_eval("private :" + m.to_s) if class_eval("@@ctors").include?(m)
	end
	
	def ctors
		class_eval("@@ctors")
	end

	#------------------------------------------------------------------------------------------

	def members(*vars)
		class_eval("@@members ||= []")
		vars.each do |v|
			class_eval("@@members << :#{v}")
		end
	end
	
	def class_members
		class_eval("@@members")
	end
	
end # ClassMethods

#----------------------------------------------------------------------------------------------

end # module Bento

#----------------------------------------------------------------------------------------------

#module Kernel
#  alias_method :bb, :byebug
#end

#----------------------------------------------------------------------------------------------
