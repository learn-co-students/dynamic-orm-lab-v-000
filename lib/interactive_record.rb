require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(name, grade, id)
    @name = name
    @grade = grade
    @id = id

    # (options={})
    # options.each do |property, value|
    #   self.send("#{property}=", value)

  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # DB[:conn].execute(PRAGMA table_info(students))
    # DB[:conn].results_as_hash = true


table_info = DB[:conn].execute(sql)
column_names = []
table_info.each do |row|
  column_names << row["name"]
end
column_names.compact
end
    def attr_accessor
      self.column_names.each do |col_name|
      attr_accessor col_name.to_sym



  #   SHOW COLUMNS
  # FROM tbl_name
    end
  end

  def table_name_for_insert
    DB[:conn].execute('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES')
    # self.class.table_name
# SELECT * FROM databaseName.INFORMATION_SCHEMA.TABLES')
  end

  def col_names_for_insert
    DB[:conn].execute('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = students')
# self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    DB[:conn].execute('LOWER(self.class.column_names);')

    values = []
self.class.column_names.each do |col_name|
  values << "'#{send(col_name)}'" unless send(col_name).nil?
end
values.join(", ")


  #   def values_for_insert
  # values = []
  # self.class.column_names.each do |col_name|
  #   values << "'#{send(col_name)}'" unless send(col_name).nil?
  # end
  # values.join(", ")
end
    # SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' CHANGE `', COLUMN_NAME, '` `',
# LOWER(COLUMN_NAME), '` ', COLUMN_TYPE, ';')
# FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '{your schema name}'
#     UPDATE table
# SET tag = LOWER(tag)
# WHERE LOWER(tag) != tag
# COLLATE Latin1_General_CS_AS


  def save
    sql = "INSERT INTO students (name, grade) VALUES name, grade;"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT * FROM students ORDER BY ID DESC LIMIT 1")
  end

  def self.find_by_name(name)
    DB[:conn].execute('SELECT * FROM students WHERE NAME = ?')
  end

  def self.find_by(name)
    DB[:conn].execute('SELECT * FROM students WHERE name = ?')
  end

end
