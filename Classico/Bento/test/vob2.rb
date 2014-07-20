require 'minitest/autorun'
require 'Bento.rb'

class VOB1 < Minitest::Test

	def setup
		# @vob = Bento::ClearCASE::VOB.unpack('', :jazz, file: 'test.vob.zip')
		# @view = Bento::ClearCASE::View.create(ENV['USERNAME'] + '_' + Bento.rand_name, root_vob: @vob.name)
		@vob = Bento::ClearCASE::VOB.new('', file: 'test.vob.zip')
	end

	def teardown
		@view.remove!
		@vob.remove!
	end

	def test_1
		assert_equal true, File.directory?(@view.path)
		assert_equal true, File.directory?(@view.path) + '/rvfc'
	end 
end
