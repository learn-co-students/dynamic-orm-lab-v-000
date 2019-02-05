require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  attr_accessor :name, :grade

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    allcolumn = DB[:conn].execute(sql)
    columname = []
    allcolumn.each do |column|
      columname << column["name"]
    end
    columname.compact
  end

  def initialize
    @name = name
    @grade = grade
  end
end
