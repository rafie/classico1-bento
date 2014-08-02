require 'minitest'

module Bento

#----------------------------------------------------------------------------------------------

class Test < Minitest::Test

	@@objects = Hash.new

	class << self; attr_accessor :before_class end
	@before_class = false
	@@test_object = nil
	
	def self.genesis
		Minitest.after_run { @@test_object._after if @@test_object != nil }
	end
	genesis
	
	def live_to_tell
		yield
		rescue => x
			self.failures << Minitest::UnexpectedError.new(x)
	end

	def setup
		if !self.class.before_class
			@@test_object._after if @@test_object != nil

			self.class.before_class = true
			@@test_object = self

			@@objects[object_id] = self
			ObjectSpace.define_finalizer(self, proc { |id| Test.finalize(id) })

			live_to_tell { _before }
		end
	end
	
	def self.finalize(id)
		x = @@objects[id]
		x._finally if x
	end

	def _before(final = true)
		live_to_tell { before if final }
	end

	def _after(final = true)
		live_to_tell { after if final }
	end

	def _finally(final = true)
		live_to_tell { finally if final }
	end

	def before; end
	def after; end
	def finally; end
end

#----------------------------------------------------------------------------------------------

end # module Bento
