require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id

  def initialize name, grade
    @id = nil
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-sql
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
      )
    sql

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if @id
      self.update
    else
      sql = <<-sql
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      sql

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-sql
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    sql

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create name, grade
    new_student = Student.new name, grade
    new_student.save
    new_student
  end

  def self.new_from_db row
    new_student = self.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def self.find_by_name name
    sql = <<-sql
      SELECT *
      FROM students
      WHERE name = ?
    sql

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db row
  end
end
