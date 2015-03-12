require 'minitest/autorun'
require 'Bento'

class Test1 < Minitest::Test

	def create_fs?; false; end
	def create_vob?; false; end

	def setup
		@user = System.user.downcase
	end

	def u(x)
		@user + "_" + x
	end

	def test_1_no_raw
		view = ClearCASE.View('')
		assert_equal u(view.name), view.tag
		assert_equal nil, view.root_vob
		
		view = ClearCASE.View('foo')
		assert_equal "foo", view.name
		assert_equal u("foo"), view.tag
		assert_equal nil, view.root_vob

		view = ClearCASE.View('foo/.bar')
		assert_equal "foo/.bar", view.name
		assert_equal u("foo"), view.tag
		assert_equal ".bar", view.root_vob.name

		view = ClearCASE.View('foo/.')
		assert_match /^foo\/\.(.+)/, view.name
		refute_equal u(view.name), view.tag
		assert_equal u("foo"), view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, u(view.name)

		view = ClearCASE.View('/.')
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, u(view.name)
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
	
	def test_2
		vob = ClearCASE.VOB('bar')
		#byebug
		view = ClearCASE.View('foo', :raw, root_vob: vob)
		assert_equal "foo/bar", view.name
		assert_equal "foo", view.tag
		assert_equal "bar", view.root_vob.name
	end
end
