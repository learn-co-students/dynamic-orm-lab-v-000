require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

#create table_name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  #create column_names
  def self.column_names
    #makes the results from the DB come back as hashes
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    #table_info will be the results of the sql statement above
    table_info = DB[:conn].execute(sql)
    #create an array to store the names of the column_names
    column_names =[]
    #iterate over the resulting array of hashes to collect just the names of the columns
    table_info.each do |row|
      column_names << row["name"]
    end
    #use .compact to make sure we dont collect any nil values
    column_names.compact
  end

  # initialize will take in the argument of options, which will be an empty hash
  # We do this becuase we expect the new instance to be called with a hash.
  #this is creating attr_accessor's so we also need to code the student.rb file to have the student.rb get its attr_accessor
  #from this method as well.
  def initialize(options={})
    #we iterate over each hash, which has a property and a value.
    options.each do |property, value|
      #each property will be used to create the attr_accessor using the .send method to set the property
      #equal to the key value
      self.send("#{property}=", value)
    end
  end

  #### METHODS FOR save ###########

  def table_name_for_insert
    #we use self.class to call the class method table_name
    self.class.table_name
  end

  def col_names_for_insert
    #Id's are generated automatically, we need to remove the id from the array of column names and
    #then join the column_names into a comma separated list.
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    #create an empty array to store the values
    values = []
    #iterate over the column_names
    #use the .send method with each individual column name to invoke the method by that same name and
    #capture the return value
    self.class.column_names.each do |col_name|
      #push the return value of invoking a method via the .send method, unless the value is nil
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    #comma separated
    #value for our SQL Statement we will put in the save method
    values.join(", ")
  end

 ######## END METHODS for save############

   def save
     #use the SQL statements created in the methods for save area
     sql = <<-SQL
     INSERT INTO #{table_name_for_insert}
     (#{col_names_for_insert})
     VALUES (#{values_for_insert})
     SQL
     DB[:conn].execute(sql)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
   end


   def self.find_by_name(name)
     sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = "#{name}"
     SQL

     DB[:conn].execute(sql)
   end

    def self.find_by(attribute)
      #accounts for when an attribute value is an integer
      value = attribute.values[0]
      new_value = value.class == Fixnum ? value : "'#{value}'"

      #executes the SQL to find a row by the attribute passed into the method
      sql = <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE #{attribute.keys[0]} = #{new_value}
      SQL

      DB[:conn].execute(sql)

    end

end
