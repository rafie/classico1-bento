
require 'byebug'

module Mojo

#----------------------------------------------------------------------------------------------

module Class

	def self.included(base)
		base.extend(ClassMethods::All)
	end

end # Class

#----------------------------------------------------------------------------------------------

module ClassMethods

#----------------------------------------------------------------------------------------------

module Constructors

	EYES_SHUT = false

	def constructors(*ctors)
		class_eval("@@ctors ||= []")
		class_eval("@@ctors += " + ctors.to_s)

		fq_klass = self.name
		
		# for self.name == A::B::C, klass == B::C
		klass = self.name.split("::")[-1]
		
		# for self.name == A::B::C, mod == A::B
		mod = eval(self.name.split("::")[0..-2].join("::"))

		class_eval("private_class_method :new", __FILE__, __LINE__)

		ctors.each do |ctor|
			if ctor == :is
				# this enables the A::B.C(...) syntax for C.is

if EYES_SHUT
				mod.module_eval(<<-END, __FILE__, __LINE__)
					def self.#{klass.to_sym}(*args)
						x = eval("#{fq_klass}").send(:new)
						x.send(:is, *args)
						x
					end
				END
else
				mod.define_singleton_method(klass.to_sym) do |*args|
					x = eval(fq_klass).send(:new)
					x.send(:is, *args)
					x
				end
end #  EYES_SHUT
			end
			
			class_eval("private :" + ctor.to_s) rescue ''

			class_eval(<<-END, __FILE__, __LINE__+1)
				def self.#{ctor}(*args)
					x = self.send(:new)
					x.send(:#{ctor}, *args)
					x
				end
			END
		end
	end
	
	def self._method_added(c, m)
		c.class_eval("@@ctors ||= []", __FILE__, __LINE__)
		c.class_eval("private :" + m.to_s, __FILE__, __LINE__) if c.class_eval("@@ctors").include?(m)
	end
	
	def ctors
		class_eval("@@ctors")
	end

end # Constructors

#----------------------------------------------------------------------------------------------

module All
	include ClassMethods::Constructors

	def method_added(m)
		ClassMethods::Constructors._method_added(self, m)
		super
	end

	def method_missing(m, *args)
		# return if ClassMethods::Constructors._method_missing(self, m, *args)
		super
	end
end

#----------------------------------------------------------------------------------------------

end # ClassMethods

#----------------------------------------------------------------------------------------------

end # module Mojo

#----------------------------------------------------------------------------------------------

module Kernel
	if Kernel.methods.include?(:byebug)
		alias_method :bb, :byebug
	else
		def bb; end
	end
end

#----------------------------------------------------------------------------------------------

module M

class A
	include Mojo::Class
	constructors :is, :create
	
	def is(id)
		@id = id
	end
	
	def create(name, value)
		@name = name
		@value = value
	end
	
	def foo
		@name
	end
end # A

end # M

#----------------------------------------------------------------------------------------------

bb
a = M.A(10)
a = M::A.create('jojo', 17)
puts a.foo
