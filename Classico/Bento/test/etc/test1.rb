
require 'minitest/autorun'
require '../lib/Test'

#----------------------------------------------------------------------------------------------

class Test1 < Bento::Test

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
		puts self.class.name + ": " + self.name
	end

	def test_2
		puts self.class.name + ": " + self.name
	end

end

class Test1a < Test1
end

class Test1b < Test1
end
