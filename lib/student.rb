require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade 
  attr_reader :id # you can only view the id not change it.

  def initialize(id = nil, name, grade) # id 1st for recalling data from database
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students ( -- creates table with columns
        id INTEGER PRIMARY KEY,             -- if it doesn't already exist
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql) # executes query
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students 
    SQL
    DB[:conn].execute(sql)  # executes query
  end

  def save
    if self.id == nil   # if nil (never been assigned)
      sql = <<-SQL
        INSERT INTO students (name, grade) -- insert into row
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade) # executes query with arguments
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]  # assigns primary key to @id
      self  #=> instance
    else
      self.update # updates the row that is already there
    end
  end

  def self.create(name, grade)
    self.new(name, grade).save  # creates new instance AND saves to database
  end

  def self.new_from_db(row)   # takes raw data and creates instance 
    self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name) 
    sql = <<-SQL
      SELECT * FROM students  -- query to find match by name
      WHERE name == ?
    SQL
    DB[:conn].execute(sql, name).map {|student|   # executes query
      self.new_from_db(student)   # creates instances
    }.first #=> first instance
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ? -- uses unique id to find row and update name and grade
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id) # executes query with arguments
  end
end
