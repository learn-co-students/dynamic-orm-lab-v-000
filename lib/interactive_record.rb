require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize(atts={})
    atts.each do |k, v|
      self.__send__("#{k}=", v)
    end
  end
  
  class << self
    def table_name
        self.to_s.downcase.pluralize
    end
    
    def column_names
      sql = <<-SQL
        PRAGMA table_info("#{table_name}");
      SQL

      table_data = DB[:conn].execute(sql)
      table_column_names = []
      
      table_data.each do |row|
        table_column_names << row["name"]
      end
      
      table_column_names.compact
    end
    
    def find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM #{table_name}
        WHERE name = ?;
      SQL
      
      DB[:conn].execute(sql, name)
    end
    
    def find_by(col_val)
      found = []
      
      col_val.each do |col, val|
        sql = <<-SQL
          SELECT *
          FROM #{table_name}
          WHERE #{col} = '#{val}';
        SQL
        
        found << DB[:conn].execute(sql)[0] 
      end

      found
    end
  end
  
  
  
  def save
    table   = self.table_name_for_insert
    columns = self.col_names_for_insert
    values  = self.values_for_insert
    
    #Question: is this not insecure? Can it be done using bind variables?
    sql = <<-SQL
      INSERT INTO #{table}(#{columns})
      VALUES (#{values});
    SQL

    DB[:conn].execute(sql)
    
    get_id = <<-SQL
      SELECT id
      FROM #{table}
      ORDER BY id
      DESC
      LIMIT 1;
    SQL
    
    @id = DB[:conn].execute(get_id).first["id"]
  end
  
  def values_for_insert
    values = []
    
    self.class.column_names.each do |col|
      v = self.__send__("#{col}")
      values << "'#{v}'" unless v.nil?
    end
    
    values.join(", ")
  end
  
  def col_names_for_insert
    columns = self.class.column_names.reject { |col| col=="id"}
    columns.join(", ")
  end
  
  def table_name_for_insert
    self.class.table_name.to_s
  end
end