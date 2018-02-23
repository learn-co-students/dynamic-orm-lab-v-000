require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
      self.to_s.downcase.pluralize
    end

    def self.column_names
      # We grab the column name keys from the hash
      DB[:conn].results_as_hash = true
      sql = "PRAGMA table_info('#{table_name}')"

      table_info = DB[:conn].execute(sql)
      column_names = []

      table_info.each do |column|
        column_names << column["name"]
      end
      column_names.compact
    end

    def initialize(options={})
      # We ask for a hash input, iterate through make the key = it's value with the .send method
      options.each do |property, value|
        self.send("#{property}=", value)
      end
    end

    def table_name_for_insert
      # We grab the class which is an instnace, get the class of that instance, and then run the class method table_name
      self.class.table_name
    end

    def col_names_for_insert
      # This returns an array ["id", "name", "grade"] and we remove the id and turn the array into a string
      # Returning values we'll insert for the column names
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
      # We want the values of the class's attribute accessors without calling them
      # We iterate over the column_names method and use the send method to get the values we want
      # We don't push col name into the values array if it's nil because the id will be nil
      # We turn the values array into a string
      values = []
      self.class.column_names.each do |col_name|
        # binding.pry
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
    end

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

      DB[:conn].execute(sql)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
      # Calling table name method calls the value for any table we're working with
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
    end

    def self.find_by(hash)
      # executes the SQL to find a row by the attribute passed into the method
      # accounts for when an attribute value is an integer
      # I turned the key into a string so I can run it in the query
      find = []
      hash.each do |key, value|
        find << key.to_s
        find << value
      end
      sql = "SELECT * FROM #{self.table_name} WHERE #{find[0]} = '#{find[1]}'"
      DB[:conn].execute(sql)
    end
end
