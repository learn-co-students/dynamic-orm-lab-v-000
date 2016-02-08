require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

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

  def col_names_for_insert
    self.class.column_names.drop(1).join(', ')
  end

  def values_for_insert
  end

  def table_name_for_insert
    self.class.table_name
  end

end

# binding.pry