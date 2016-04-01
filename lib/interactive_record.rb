require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


end

def update
    sql = <<-SQL
    UPDATE students 
    SET name = ?, 
    grade = ? 
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end