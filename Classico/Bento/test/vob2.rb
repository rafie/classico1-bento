require 'Bento'
require 'minitest/autorun'

class VOB1 < Minitest::Test

	def setup
		@vob = ClearCASE::VOB.create('', file: 'test.vob.zip')
		@view = ClearCASE::View.create('/' + @vob.name)
	end

	def teardown
		byebug
		@vob.remove!
		raise "VOB #{@vob.name} still mounted!" if File.directory?(@view.path)
		@view.remove!
	end

	def test_1
		assert_equal true, File.directory?(@view.path)
		assert_equal true, File.directory?(@view.path + '/rvfc')
	end 
end
