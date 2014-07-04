
# require 'byebug'

module Bento

#----------------------------------------------------------------------------------------------

module Class

	# if opt.include? :flag, @flag = true
	def init_flags(flags, opt)
		rest = opt.dup
		flags.each do |f|
			if rest.include? f
				instance_variable_set("@#{f}", true)
				rest.delete f
			end
		end
		return rest
	end

	# if opt.include? tag, invole method tag(*args)
	def tagged_init(tag, opt, args)
		return false if !opt.include? tag
		send(tag, *args)
		return true
	end

end # BentoClass

#----------------------------------------------------------------------------------------------

end # module Bento

#----------------------------------------------------------------------------------------------

#module Kernel
#  alias_method :bb, :byebug
#end

#----------------------------------------------------------------------------------------------
