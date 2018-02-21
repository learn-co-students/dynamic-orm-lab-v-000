require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def initialize(options={})
      options.each do |property, value|
        self.send("#{property}=",value)
      end
    end

    def self.table_name
      "#{self.to_s.downcase}" + "s"
    end

    def self.column_names
      DB[:conn].results_as_hash = true

      sql = "pragma table_info('#{table_name}')"

      table_info = DB[:conn].execute(sql)
      columns = []
      table_info.each do |row|
        columns << row["name"]
      end
      columns
    end


    def table_name_for_insert
      self.class.table_name
    end

    def col_names_for_insert
      self.class.column_names.delete_if {|column| column == "id"}.join(", ")
    end

    def values_for_insert
      values_array = []
      self.class.column_names.each do |name|
        values_array << "'#{send(name)}'" unless send(name).nil?
      end
      values_array.join(", ")
    end

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
    end

    def self.find_by(attributes)
      value = attributes.values.first
      formatted_value = value.class == Fixnum ? value : "'#{value}'"
      sql = "SELECT * FROM #{self.table_name} WHERE #{attributes.keys.first} = #{formatted_value}"
      DB[:conn].execute(sql)
    end
end
