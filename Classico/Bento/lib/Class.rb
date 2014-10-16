
# require 'byebug'

module Bento

#----------------------------------------------------------------------------------------------

module Class

	def self.included(base)
		base.extend(ClassMethods::All)
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

#----------------------------------------------------------------------------------------------

module Constructors

	def constructors(*ctors)
		class_eval("@@ctors ||= []")
		class_eval("@@ctors += " + ctors.to_s)
	
		klass = self.name.split("::")[-2..-1].join("::")
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
	
	def self._method_added(c, m)
		c.class_eval("@@ctors ||= []")
		c.class_eval("private :" + m.to_s) if c.class_eval("@@ctors").include?(m)
	end
	
	def ctors
		class_eval("@@ctors")
	end

	#------------------------------------------------------------------------------------------

	def members(*vars)
		class_eval("@@members ||= []")
		vars.each do |v|
			if v.is_a?(Symbol)
				class_eval("@@members << :#{v}") 
			else
				class_eval("@@members << #{v.to_s}")
			end
		end
	end
	
	def class_members
		class_eval("@@members")
	end
	
end # Constructors

#----------------------------------------------------------------------------------------------

# based on Jorg W Mittag's work:
# http://stackoverflow.com/questions/3157426/how-to-simulate-java-like-annotations-in-ruby

module Annotations

	def annotations(m = nil)
		return @__annotations__[m] if m
		@__annotations__
	end
 
	def self._method_added(c, m)
		c.class_eval("@__annotations__ ||= {}")
		last1 = c.class_eval("@__last_annotation__")
		c.class_eval("@__annotations__")[m] = last1 if last1
		c.class_eval("@__last_annotation__ = nil")
	end

	def self._method_missing(c, m, *args)
		return false unless /\A_/ =~ m
		c.class_eval("@__last_annotation__ ||= {}")
		c.class_eval("@__last_annotation__")[m[1..-1].to_sym] = args.size == 1 ? args.first : args
		true
	end
end

#----------------------------------------------------------------------------------------------

module All
	include ClassMethods::Constructors
	include ClassMethods::Annotations

	def method_added(m)
		ClassMethods::Constructors._method_added(self, m)
		ClassMethods::Annotations._method_added(self, m)
		super
	end

	def method_missing(m, *args)
		return if ClassMethods::Annotations._method_missing(self, m, *args)
		super
	end
end

#----------------------------------------------------------------------------------------------

end # ClassMethods

#----------------------------------------------------------------------------------------------

end # module Bento

#----------------------------------------------------------------------------------------------

#module Kernel
#  alias_method :bb, :byebug
#end

#----------------------------------------------------------------------------------------------
