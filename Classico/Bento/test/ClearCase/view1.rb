require 'minitest/autorun'
require '../../..Bento'

class View1 < Minitest::Test

	# def create_vob?; true; end

	def setup
		@vob = ClearCASE::VOB.create('', file: 'test.vob.zip')
		@view = ClearCASE::View.create('/' + @vob.name)
	end

	def teardown
		@view.remove!
		@vob.remove!

		super()
	end

	def test_view_name
		byebug
		assert_equal true, @view.name.include?("/")
	end 
end
