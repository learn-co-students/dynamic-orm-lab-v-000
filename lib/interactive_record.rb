require_relative "../config/environment.rb"


class InteractiveRecord
  
  def self.table_name
		self.to_s.downcase.pluralize
	end

end