require 'Bento'
require 'minitest/autorun'

class VOB1 < Minitest::Test

	def setup
		# @vob = Bento::ClearCASE::VOB.unpack('', :jazz, file: 'test.vob.zip')
		# @view = Bento::ClearCASE::View.create(ENV['USERNAME'] + '_' + Bento.rand_name, root_vob: @vob.name)
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
