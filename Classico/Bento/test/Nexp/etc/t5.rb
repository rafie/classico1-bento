
module Bento

module NEXP

class Nexp
	def is(f)
		puts "#{f} is a file"
	end 

	def from_s(s)
		puts "i'm from_s"
	end

	def self.is(*args)
		x = self.new; x.send(:is, *args); x
	end

	def self.from_s(*args)
		x = self.send(:new); x.send(:from_s, *args); x
	end
	
	private :is, :from_s
	private_class_method :new 
end

def self.Nexp(*args)
	x = Nexp.send(:new); x.send(:is, *args); x
end

end # NEXP

Nexp = NEXP::Nexp

end # module Bento

#------------------------------------------------------------------------------

# n1 = Bento::Nexp.Nexp("file")
# n2 = Bento::Nexp::Nexp.from_s("()")

NExp = Bento::NEXP::Nexp

def Nexp(*args)
	Bento::NEXP.Nexp(*args)
end

#------------------------------------------------------------------------------

n1 = Nexp("file")
n2 = Bento::Nexp.from_s("(nexp)")
n3 = NExp.from_s("(nexp)")
