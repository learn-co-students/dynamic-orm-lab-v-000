require 'pry'
class Whatever
	def self.do_this
		print "yes"
		binding.pry
	end

	self.do_this
end