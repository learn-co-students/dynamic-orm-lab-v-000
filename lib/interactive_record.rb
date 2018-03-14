require_relative "../config/environment.rb"
require 'active_support/inflector'
#==========================================================================
class InteractiveRecord
#===============================initialize=================================
  def initialize(attrs={})
    attrs.each{|a, v| self.send("#{a}=", v)}
  end
#=================================table====================================
  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    DB[:conn].results_as_hash = true and data = DB[:conn].execute("pragma table_info('#{table_name}')")
    
    cols = [] and data.each{|row| cols << row["name"]} and cols.compact
  end
#=========================prepare for save/insert==========================
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(', ')
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each{|col| values << "'#{self.send(col)}'" unless self.send(col).nil? } and values.join(", ") 
  end
#=================================actions==================================
  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end
  
  def self.find_by(attrs)
    key, value = attrs.first
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = ?", value)
  end
#==========================================================================
end