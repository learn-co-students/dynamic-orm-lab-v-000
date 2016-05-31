require_relative "../config/environment.rb"
require 'active_support/inflector'
require_relative 'student.rb'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = <<-SQL
      PRAGMA table_info('#{table_name}')
    SQL

    table_info = DB[:conn].execute(sql)
    #binding.pry
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    #binding.pry
    column_names.compact
  end

  self.column_names.each do |col_name|
    binding.pry
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    #binding.pry
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
end
