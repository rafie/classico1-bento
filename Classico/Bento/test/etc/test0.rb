
require 'minitest/autorun'

#----------------------------------------------------------------------------------------------

class MyTest < Minitest::Test

	@@objects = Hash.new

	class << self; attr_accessor :before_class end
	@before_class = false
	@@test_object = nil
	
	def self.genesis
		Minitest.after_run {
 			 @@test_object.after if @@test_object != nil
		}
	end
	genesis
	
	def setup
#1		if !defined?(@@before_class)
#1			@@before_class = true
#2		if !instance_variable_get(:@before_class)
#2			instance_variable_set(:@before_class, true)
#3		if !self.class.before_class
#3			self.class.before_class = true

		if !self.class.before_class
			@@test_object.after if @@test_object != nil

			before

			self.class.before_class = true
			@@test_object = self

			@@objects[object_id] = self
			ObjectSpace.define_finalizer(self, proc { |id| MyTest.finalize(id) })
		end
	end
	
	def self.finalize(id)
		x = @@objects[id]
		x.finally if x
	end

	def before
	end

	def after
	end
	
	def finally
	end
end

#----------------------------------------------------------------------------------------------

class Test1 < MyTest

	def before
		puts "\n" + self.class.name + ": before class"
	end

	def after
		puts self.class.name + ": after class"
	end

	def finally
		puts self.class.name + ": finally"
	end

	def setup
		super()
		puts self.class.name + ": setup"
	end

	def teardown
		puts self.class.name + ": teardown"
	end

	def test_1
		puts self.class.name + ": test_1"
	end

	def test_2
		puts self.class.name + ": test_2"
	end

end

class Test1a < Test1
end

class Test1b < Test1
end
