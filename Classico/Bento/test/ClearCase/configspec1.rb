require 'minitest/autorun'

require 'Bento'
require 'Bento/lib/Test'

class Test1 < Bento::Test

	def create_fs?; false; end
	def create_vob?; false; end

	@@nobranch = <<END
element * CHECKEDOUT

element /rvfc/... rvfc_2.0
element /mcu/... mcu_1.0

element * /main/0
END

	@@branch = <<END
element * CHECKEDOUT

element * .../act1_br/LATEST
mkbranch act1_br
element /rvfc/... rvfc_2.0
element /mcu/... mcu_1.0

element * /main/0
end mkbranch
END
	
	@@nobranch_tag = <<END
element * CHECKEDOUT

element * baseline1

element /rvfc/... rvfc_2.0
element /mcu/... mcu_1.0

element * /main/0
END

	@@nobranch_checks = <<END
element * CHECKEDOUT

element * c3
element * c2
element * c1

element /rvfc/... rvfc_2.0
element /mcu/... mcu_1.0

element * /main/0
END

	
	def compact(s)
		a1 = s.lines.keep_if {|x| x != "\n"}
		s2 = a1.map { |s| s.gsub(/[ \t]+/, " ") }
		s2.join
	end
	
	def test_nobranch
		c1 = ClearCASE.Configspec(vobs: {:rvfc => "rvfc_2.0", :mcu => "mcu_1.0"})
		assert_equal compact(@@nobranch), compact(c1.to_s)
	end

	def test_branch
		c1 = ClearCASE.Configspec(vobs: {:rvfc => "rvfc_2.0", :mcu => "mcu_1.0"}, branch: "act1_br")
		assert_equal compact(@@branch), compact(c1.to_s)
	end

	def test_nobranch_tag
		c1 = ClearCASE.Configspec(vobs: {:rvfc => "rvfc_2.0", :mcu => "mcu_1.0"}, tag: "baseline1")
		assert_equal compact(@@nobranch_tag), compact(c1.to_s)
	end

	def test_nobranch_checks
		c1 = ClearCASE.Configspec(vobs: {:rvfc => "rvfc_2.0", :mcu => "mcu_1.0"}, checks: %w(c1 c2 c3))
		assert_equal compact(@@nobranch_checks), compact(c1.to_s)
	end
end
