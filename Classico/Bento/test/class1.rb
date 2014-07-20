require 'minitest/autorun'
require 'Bento'

class A
	include Bento::Class
	
	attr_reader :a, :b, :flags

	def initialize(a, *opt, b: 'no-b')
		return if tagged_init(:create, opt, [a, *opt, b: b])
		# return create(a, *opt, b) if opt.include? :create
	end
end

class Test1 < Minitest::Test
	def setup
	end

	def teardown
	end

	def A_tests(a)
		assert_equal a.a, 'a'
		assert_equal a.b, 'b'
	end

	def test_class
		#A.new('a', :flag).a, 'a'
		# A.new('a', :flag, :create)
		# A.new('a', b: 'jojo')
		# A.new('a', :flag, :red, b: 'jojo')
		A.create('a')
		A.create('a', b: 'b')
		A.create('a', :flag)
		A.create('a', :flag, b: 'b')
	end
	
end