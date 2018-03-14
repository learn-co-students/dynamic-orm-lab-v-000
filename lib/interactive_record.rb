require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

#The #pluralize method is provided to us by the active_support/inflector code library, required at the top of lib/song.rb.
  def self.table_name
    self.to_s.downcase.pluralize
  end

# We want to query a table for its column names using PRAGMA
# This will return us (hash) an array of hashes describing the table, each hash has a "name" key (column name)
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"

     table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
    #We call #compact on that just to be safe and get rid of any nil values that may end up in our collection.
  end



# initalize method to be abstract and not specific..
# We want to be able to create a new song like this: song = Song.new(name: "Hello", album: "25")
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end


#Luckily for us, we already have a method to give us the table name associated to any given class: <class name>.table_name.
# Recall, however, that the conventional #save is an instance method. So, inside a #save method, self will refer to the instance of the class, not the class itself.
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
# When we INSERT a row into a database table for the first time, we don't INSERT the id attribute.
#In fact, our Ruby object has an id of nil before it is inserted into the table.
# Therefore, we need to remove "id" from the array of column names returned from the method call above:



#Let's iterate over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:
  def values_for_insert
    values = []
     self.class.column_names.each do |col_name|
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
     sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
     DB[:conn].execute(sql)
     # without the single quotes around #{name} it gives error - no such column Jan
   end

   def self.find_by(attribute_hash)
      value = attribute_hash.values.first
      formatted_value = value.class == Fixnum ? value : "'#{value}'"
      sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
      DB[:conn].execute(sql)
    end

end
