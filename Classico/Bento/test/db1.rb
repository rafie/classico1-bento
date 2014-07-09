
require 'minitest/autorun'
require 'Bento.rb'
require 'byebug'

class Test1 < Minitest::Test
	def setup
		byebug
		@db = Bento::DB.create() << <<-SQL
create table numbers (name varchar(30), val int);
SQL
	end

	def teardown
		@db.cleanup
	end

	def test_insert
		@db << ("insert into numbers values (?, ?)", ['jojo', 17]))
		assert_equal 'jojo', @db["select * from numbers where val = ?", 17][:name]
	end
end
