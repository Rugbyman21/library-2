class Patrons
  attr_reader(:name, :id)

  define_method(:initialize) do |attributes|
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)

  end

  define_singleton_method(:all) do
    returned_patrons = DB.exec("SELECT * FROM patrons;")
    patrons = []
    returned_patrons.each() do |patron|
      name = patron.fetch("name")
      id = patron.fetch("id").to_i()
      patrons.push(Patrons.new({:name => name, :id => id}))
    end
    patrons
  end

  define_method(:save) do

    result=DB.exec("INSERT INTO patrons (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i()
  end

  define_method(:==) do |another_patron|
    self.name().==(another_patron.name()).&(self.id().==(another_patron.id()))
  end

  define_method(:update) do |attributes|
    @name = attributes.fetch(:name, @name)
    DB.exec("UPDATE patrons SET name = '#{@name}' WHERE id = #{self.id()};")

    attributes.fetch(:book_ids, []).each() do |book_id|
      DB.exec("INSERT INTO patrons_books(patron_id, book_id) VALUES (#{self.id()}, #{book_id});")
  end
end

  define_method(:delete) do
    DB.exec("DELETE FROM patrons_books WHERE patron_id = #{self.id()};")
    DB.exec("DELETE FROM books WHERE id = #{self.id()};")
  end

  define_method(:books) do
    patron_books = []
    results = DB.exec("SELECT book_id FROM patrons_books WHERE patron_id = #{self.id()};")
    results.each() do |result|
    book_id = result.fetch("book_id").to_i()
      book = DB.exec("SELECT * FROM books WHERE id = #{book_id};")
      name = book.first().fetch("name")
      patron_books.push(Books.new({:name => name, :id => book_id}))
    end
    patron_books
  end




end
