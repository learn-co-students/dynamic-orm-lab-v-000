#Dynamic ORM Lab

## Objectives

1. Construct an ORM superclass that can be used for multiple classes
2. Inherit the methods from the ORM class to the Student class

## Dynamic ORMs & Inheritance

By this point, we've learned the value of a dynamic ORM -- a way to write an ORM that is almost entirely abstract. The key takeaway is that this ORM is *not specific to any one class*. The code will live in one class (the superclass) and be inherited to any class (child class) we wish to have access to the ORM methods.

Now that we've had some practice with this, let's build out a dynamic ORM that can be inherited to any class.

## Let's get started

### The Super Class

In the `lib` directory, you'll see the `interactive_record.rb` file. This file is where almost all of your ORM code will live. Once you set this up, you will share the methods in this class with the child class.


### The Child Class

Your `Student` class lives in `lib/student.rb`. This class will inherit from `InteractiveRecord`. ***Your methods won't be written in this class.*** All of the methods defined in `InteractiveRecord` will be available to `Student` once you set up the inheritance.

Note: The only code the `Student` class needs to contain is the code to create the `attr_accessor`s specific to itself. But even that code uses a method, `#column_names`, inherited from the super class.

This is a test-driven lab, so run the specs and get them to pass. (Note:
You might need to install some dependencies to get the tests running — that's
okay! As Jedi Master Obi-Wan Kenobi would say, "Use the Gemfile, Luke!")



<p data-visibility='hidden'>View <a href='https://learn.co/lessons/dynamic-orm-lab' title='Dynamic ORM Lab'>Dynamic ORM Lab</a> on Learn.co and start learning to code for free.</p>


<!-- def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end -->
