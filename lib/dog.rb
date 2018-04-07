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


  def self.find_or_create_by(name:, breed:)
  dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if !dog_data.empty?
      # stuff = dog_data[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(name:name, breed:breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    #binding.pry
    result = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new(id:result[0], name:result[1], breed:result[2])
    new_dog
  end

  def self.find_by_id(id)
    sql =<<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    #binding.pry
    result = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(id:result[0], name:result[1], breed:result[2])
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
