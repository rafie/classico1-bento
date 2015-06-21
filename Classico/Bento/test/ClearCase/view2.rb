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
		view = ClearCASE::View.create('', :nop)
		assert_equal u(view.nick), view.tag
		assert_equal view.name, view.tag
		assert_equal nil, view.root_vob

		assert_raises(RuntimeError) do
			view = ClearCASE.View('')
		end

		view = ClearCASE.View('foo')
		assert_equal "foo", view.nick
		assert_equal u("foo"), view.name
		assert_equal u("foo"), view.tag
		assert_equal nil, view.root_vob

		view = ClearCASE.View('foo/.bar')
		assert_equal "foo", view.nick
		assert_equal u("foo/.bar"), view.name
		assert_equal u("foo"), view.tag
		assert_equal ".bar", view.root_vob.name

		view = ClearCASE::View.create('foo/.', :nop)
		assert_equal "foo", view.nick
		assert_match /^(.+)_foo\/\.(.+)/, view.name
		refute_equal view.name, view.tag
		assert_equal u("foo"), view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, view.name

#		assert_raises(RuntimeError) do
#			view = ClearCASE.View('foo/.')
#		end

		view = ClearCASE::View.create('/.', :nop)
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, u(view.name)
		assert view.root_vob != nil

#		assert_raises(RuntimeError) do
#			view = ClearCASE.View('/.')
#		end
	end

	def test_1_raw
		view = ClearCASE::View.create('', :raw, :nop)
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

		view = ClearCASE::View.create('foo/.', :raw, :nop)
		assert_match /^foo\/\.(.+)/, view.name
		refute_equal view.name, view.tag
		assert_equal "foo", view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, view.name

		view = ClearCASE.View('/.', :raw, :nop)
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, view.name
		assert view.root_vob != nil
	end

	def test_1_name
		view = ClearCASE::View.create(nil, :nop, name: '')
		assert_equal view.tag, view.name
		assert_equal nil, view.root_vob
		
		view = ClearCASE.View(nil, name: 'foo')
		assert_equal "foo", view.name
		assert_equal "foo", view.tag
		assert_equal nil, view.root_vob

		view = ClearCASE.View(nil, name: 'foo/.bar')
		assert_equal "foo/.bar", view.name
		assert_equal "foo", view.tag
		assert_equal ".bar", view.root_vob.name

		view = ClearCASE::View.create(nil, :nop, name: 'foo/.')
		assert_match /^foo\/\.(.+)/, view.name
		refute_equal view.name, view.tag
		assert_equal "foo", view.tag
		assert view.root_vob != nil
		assert_equal view.tag + "/" + view.root_vob.name, view.name

		view = ClearCASE.View(nil, :nop, name: '/.')
		assert_match /^(.+)\/\.(.+)/, view.name
		refute_equal view.tag, view.name
		assert view.root_vob != nil
	end
	
	def test_2
		vob = ClearCASE.VOB('bar')
		view = ClearCASE.View('foo', :raw, root_vob: vob)
		assert_equal "foo/bar", view.name
		assert_equal "foo", view.tag
		assert_equal "bar", view.root_vob.name
	end
end
