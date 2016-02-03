require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    col_array = []
    sql = <<-SQL
      PRAGMA table_info('students')
    SQL
    DB[:conn].execute(sql).each { |idx| col_array << idx['name']}
    col_array
  end
end

#binding.pry