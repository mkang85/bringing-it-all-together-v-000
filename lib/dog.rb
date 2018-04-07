class Dog
attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id:row[0], name:row[1], breed:row[2])
    new_dog
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name:name, breed:breed)
    new_dog.save
    new_dog
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
    self
  end

  def self.find_by_name(name)
    sql =<<-SQL
    FIND *
    FROM dogs
    WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name)
    new_dog = Dog.new(result[0], result[1], result[2])
    new_dog
  end

end
