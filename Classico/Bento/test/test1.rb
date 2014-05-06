require "minitest/autorun"

class Test1 < Minitest::Test
	def setup
	end

	def teardown
	end

	def test_that_kitty_can_eat
		assert 1 == 1
	end

	def test_that_it_will_not_blend
		refute 0 == 1
	end

	def test_that_will_be_skipped
		skip "test this later"
	end
end
