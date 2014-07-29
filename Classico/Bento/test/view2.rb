require 'minitest/autorun'
require 'Bento'

class View1 < Minitest::Test

	def create_fs?; false; end
	def create_vob?; false; end

	def setup
		@user = System.user.downcase
	end

	def u(x)
		@user + "_" + x
	end

	def test_1
		view = ClearCASE.View('')
		assert_equal view.name, view.tag
		assert_equal nil, view.root_vob
		
		view = ClearCASE.View('foo')
		assert_equal u("foo"), view.name
		assert_equal u("foo"), view.tag
		assert_equal nil, view.root_vob

		view = ClearCASE.View('foo/.bar')
		assert_equal u("foo/.bar"), view.name
		assert_equal u("foo"), view.tag
		assert_equal ".bar", view.root_vob.name

		view = ClearCASE.View('foo/.')
		assert_match /^#{u("foo")}\/\.(.+)/, view.name
		refute_equal view.name, view.tag
		assert_equal u("foo"), view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, view.name

		view = ClearCASE.View('/.')
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, view.name
		assert view.root_vob != nil
	end

	def test_1_raw
		view = ClearCASE.View('', :raw)
		assert_equal view.tag, view.name
		assert_equal nil, view.root_vob
		
		view = ClearCASE.View('foo', :raw)
		assert_equal "foo", view.name
		assert_equal "foo", view.tag
		assert_equal nil, view.root_vob

		view = ClearCASE.View('foo/.bar', :raw)
		assert_equal "foo/.bar", view.name
		assert_equal "foo", view.tag
		assert_equal ".bar", view.root_vob.name

		view = ClearCASE.View('foo/.', :raw)
		assert_match /^foo\/\.(.+)/, view.name
		refute_equal view.name, view.tag
		assert_equal "foo", view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, view.name

		view = ClearCASE.View('/.', :raw)
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, view.name
		assert view.root_vob != nil
	end
end
