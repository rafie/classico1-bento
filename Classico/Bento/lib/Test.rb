require 'minitest'

module Bento

#----------------------------------------------------------------------------------------------

class Test < Minitest::Test

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
		if !self.class.before_class
			@@test_object.after if @@test_object != nil

			before

			self.class.before_class = true
			@@test_object = self

			@@objects[object_id] = self
			ObjectSpace.define_finalizer(self, proc { |id| Test.finalize(id) })
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

end # module Bento
