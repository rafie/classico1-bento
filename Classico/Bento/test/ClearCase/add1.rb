
require 'minitest/autorun'
require 'Bento'
require '../lib/Test'
require 'fileutils'

class Test1 < Bento::Test

	def create_fs?; false; end
	def create_vob?; true; end
	
	def before
		@@vob = ClearCASE::VOB.create('', file: 'test.vob.zip')
		@@view1 = ClearCASE::View.create('', root_vob: @@vob)
		@@view2 = ClearCASE::View.create('', root_vob: @@vob)
	end

	def after
		@@view1.remove!
		@@view2.remove!
		@@vob.remove!
	end

	def test_add_file
		byebug
		root1 = @@view1.root
		FileUtils.copy_file(root1 + "/rvfc/makefile", root1 + "/rvfc/makefile1")
		@@view1.add_files(root1 + "/rvfc/makefile1")
		assert_equal File.read(root1 + "/rvfc/makefile1"), File.read(@@view2.root + "/rvfc/makefile1")
	end 
end
